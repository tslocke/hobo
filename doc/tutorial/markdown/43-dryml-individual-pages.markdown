## Writing Individual Pages

Modify the content-body parameter like this:

File: app/views/front/index.dryml

    <page>
      <content-body:>
        <h2>Recent Adverts</h2>
        <card repeat="&Advert.recent.all">
          <content:><view:body/></content:>
        </card>
      </content-body:>
    </page>
{: .dryml}
