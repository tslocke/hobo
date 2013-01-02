# Upload Progress  Bar with Hobo and Paperclip

Originally written by ignacio on 2011-06-12.

This recipe has been tested with Hobo 1.0.1 and Rails 2.3.8. 

It uses Phusion Passenger, Ajax and a iframe hack to get a nice ajax progress bar for the uploads.

Before we start, you can take a look at [the demo video I recorded](http://ihuerta.net/lang/en-us/2011/06/new-hobo-recipe-using-a-progress-bar-with-hobo/) and the [complete demo in .tar.gz](http://ihuerta.net/wp-content/uploads/2011/06/demo_progress_bar.tar.gz).

Step One: Create two tables and install paperclip
=================================================

We create the application and two tables: clients and attachments

    hobo demo_progress_bar
    cd demo_progress_bar
    script/generate hobo_model_resource client name:string
    script/generate hobo_model_resource attachment


Every *client* has_many *attachments*:

<pre class="ruby">
<code>
# app/models/client.rb
has_many :attachments
</code>
</pre>


<pre class="ruby">
<code>
# app/models/attachment.rb
belongs_to :client
</code>
</pre>

Create and run the migrations:
<pre>
script/generate hobo_migration
</pre>



Now we add the Hobo magic to connect the clients and the attachments:

<pre class="ruby">
<code>
# app/viewhints/client_hints.rb:
children :attachments
</code>
</pre>

<pre class="ruby">
<code>
# app/controllers/attachments_controller.rb:
  auto_actions :write_only
  auto_actions_for :client, :create
end
</code>
</pre>


Next we install Paperclip and Paperclip with Hobo. 
<pre>
script/plugin install git://github.com/thoughtbot/paperclip.git
script/plugin install git://github.com/tablatom/paperclip_with_hobo.git
</pre>

I found a bug between the latest paperclip and paperclip_with_hobo, so you can try this slightly older paperclip revision (untar it in vendor/plugins): http://ihuerta.net/wp-content/uploads/2011/06/Paperclip.tar.gz

<pre>
cd vendor/plugins
wget http://ihuerta.net/wp-content/uploads/2011/06/Paperclip.tar.gz
tar xzfv Paperclip.tar.gz
</pre>


Now we prepare the model, the views and the migrations

      has_attached_file :file, 
          :whiny => false, 
          :path => "#{RAILS_ROOT}/files/:id.:extension"
      validates_attachment_size :file, :less_than => 5.megabytes
      validates_attachment_presence :file


      def name
        file.original_filename
      end
      
      def size
        if (file_file_size / 1024) < 1024
          (file_file_size / 1024).to_s + ' KB'
        else
          (file_file_size / 1048576).to_s + ' MB'
        end
      end
{.ruby}








app/views/clients/show.dryml

    <show-page>
      <form: enctype="multipart/form-data">
        <field-list: fields="file"/>
      </form:>
    </show-page>



app/views/taglibs/application.dryml

    <!-- Paperclip support -->
    <include src="paperclip" plugin="paperclip_with_hobo"/>
    <def tag="input" for="Paperclip::Attachment"> 
      <%= file_field_tag param_name_for_this, attributes %> 
    </def>
    
    <!-- Card for every attachment -->
    <def tag="card" for="Attachment">
      <card class="attachment" param="default" merge>
        <header: param>
          <h4 param="heading"><a href="/attachments/download/#{this.id}"><name/></a></h4>
          <div param="actions">
            <delete-button label="X" param/>
          </div>
        </header:>
        <body:>
          <p>Size: <this.size/></p>
          <p>Date: <this.created-at/></p>
        </body:>
      </card>
    </def>





app/controllers/attachments_controller.rb

      def download
        attachment = Attachment.find(params[:id])
        send_file 'files/' + attachment.name
      end


<pre>
script/generate hobo_migration
</pre>




Step 2: Start tracking the uploads with Phusion Passenger
=========================================================

In order to track the progress of uploads, we need the server to give us that information. "Apache Upload Progress Module" is a nice extension that solves our problem.


Download https://github.com/drogus/apache-upload-progress-module

Extract it

Install it
<pre>
sudo apxs2 -c -i -a mod_upload_progress.c
</pre>

Prepare the virtualhost to track uploads:

    <VirtualHost demo_progress_bar.localhost:80>
      ServerName demo_progress_bar.localhost
      DocumentRoot '/home/ignacio/Trabajos/2_Proyectillos/Hobo/demo_progress_bar/public'
      RailsEnv development
      <Directory '/home/ignacio/Trabajos/2_Proyectillos/Hobo/demo_progress_bar/public'>
         AllowOverride all
         Options -MultiViews
      </Directory>
    
       <Location />
         # enable tracking uploads in /
         TrackUploads On
       </Location>
    
       <Location /progress>
         # enable upload progress reports in /progress
         ReportUploads On
       </Location>
    
    </VirtualHost>


And a nice tip if you are working with Ubuntu. While you are testing in localhost, it's very nice to simulate a slow upload speed so you can actually see the bar moving. I use this iprelay command and work through http://demo_progress_bar.localhost:8002
<pre>
iprelay -b350000 8002:demo_progress_bar.localhost:80
</pre>


Before we start with the upload bar, let's check if the tracking is working. First we add a test UUID to the file upload request:

app/views/clients/show.dryml:

    <% 
      # Random UUID for the upload
      uuid = (0..29).to_a.map {|x| rand(10)}.to_s
    %>
    <show-page>
      <form: enctype="multipart/form-data"
             action="/clients/#{@client.id}/attachments?X-Progress-ID=#{uuid}">
        <field-list: fields="file"/>
        <after-submit:>
          <a href="/progress/?X-Progress-ID=#{uuid}">Testing the upload URL</a>
        </after-submit:>
      </form:>
    </show-page>



When you reload the client page, you will see a link that gives you a JSON answer, something like:

<pre>
{ "state" : "starting", "uuid" : "659102713689307356231103628731" }
</pre>

This means the download hasn't yet started. If you are uploading the file, the JSON should be:

<pre>
{ "state" : "uploading", "received" : 47104, "size" : 173966, "speed" : 47104, 
"started_at": 1307856054, "uuid" : "659102713689307356231103628731" }
</pre>

With this info we are going to create the progress bar :)



Step 3: Build the progress bar
==============================

Now let's get to the fun part. First we need a JS function to take care of the progress-bar. Basically it gets the JSON info every couple of seconds, and based on the answer it decided what to do:

public/stylesheets/application.js:

    function hoboprogress(uuid){
      // Make the progress bar appear
      $('progress-bar').setStyle('display: block;');
      
      // Reload the Progress Bar every 2 seconds
      new PeriodicalExecuter(
        function(pe){
          new Ajax.Request("/progress",{
            method: 'get',
            parameters: 'X-Progress-ID='+uuid,
            onSuccess: function(xhr){
              /* When we get the upload info in JSON, we evaluate it */
              var upload = xhr.responseText.evalJSON();
              if(upload.state == 'uploading'){
                /* Calculate the percentage */
                upload.percent = Math.floor((upload.received / upload.size) * 100);
                $('progress-bar').setStyle({width: upload.percent + "%"});
                $('progress-bar').update(upload.percent + "%" + upload.speed);
              };
              /* Once we are in the 100%, we trigger some stuff */
              if(upload.state == 'done' || upload.percent == 100){
                // Stop the PeriodicalExecuter
                pe.stop();
                
                // Change the message
                $('progress-bar').update('Saving...');
                
                // Update the file list (we wait a second so the server writes the new file to the DB)
                Hobo.ajaxRequest.delay(0.8,'/clients/show/3', ['collection'],{
                  onSuccess: function(response){
                    // Hide the progress bar once the update is complete
                    $('progress-bar').fade();
                  },
                  message:false
                });
                
                // Empty the file input box
                // This is a bit complicated to do cross browser
                // Apparently, replacing the HTML works best
                $('file-input').update("<input type='file' name='attachment[file]' id='attachment_file' class='file-tag paperclip--attachment attachment-file'>");
              };
              
            }
          })
        },2
      );
    };



Ok, too much JS, I know. But the result is worth it! Now let's add the progress-bar div to the show.dryml, plus an iframe for the upload to work:


app/views/clients/show.dryml

    <% 
      # Random UUID for the upload
      uuid = (0..29).to_a.map {|x| rand(10)}.to_s
    %>
    <show-page>
      <form: enctype="multipart/form-data"
             action="/clients/#{@client.id}/attachments?X-Progress-ID=#{uuid}"
             target="jobdummy">
        <field-list: fields="file">
          <file-view: id="file-input"/>
        </field-list:>
        <submit: onclick="hoboprogress('#{uuid}', '#{@client.id}');"/>
        <after-submit:>
          <!-- Progress Bar -->
          <div id="progress-bar" style="background-color:green; color:white; font-size:20px; padding:10px; display:none;">Starting upload</div>
          <!-- Iframe for the Ajax upload -->
          <iframe id="jobdummy" name="jobdummy" 
                  style="width:0px;height:0px;top:3000px">
          </iframe> 
        </after-submit:>
      </form:>
      
      <collection: replace>
        <collection:attachments part="collection"/>
      </collection>
      
    </show-page>

Last step: make the controller answer to Ajax requests:

<pre class="ruby">
<code>
# app/controllers/clients_controller.rb
  def show
    hobo_show do
      hobo_ajax_response if request.xhr?
    end
  end
</code>
</pre>


