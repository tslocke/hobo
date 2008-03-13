# Customizing the App

In a short space of time, you have created a working app. Some parts of the generic app might
already be quite close to what you want, other parts will not. Now it is time to begin customizing
the app to your needs. 

Your initial inclination might be to dive in to `app/views` and start modifying the individual 
page views. However, you will soon find that initially there are no files for the individual 
pages in the generic app. Hobo doesn't generate the generic views in your app, they are being rendered using a set of generic page tags provided by the Hobo Rapid library. DRYML allows these page tags to be customized in powerful ways without having to re-define parts of the page that you don't want to change. 

But before we dive into DRYML we can change the behavior of the generated UI in several ways by making changes to our models and controllers, and these are a good place to start.

1. [Model Layer](31-model-layer.html)
2. [Resource Controllers](32-resource-controllers.html)
