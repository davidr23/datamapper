require 'sinatra/base'
require './datamapper' # Lädt den Code aus der `datamapper.rb`-Datei--without=production
require 'dm-core' 

class MyApp < Sinatra::Base
  enable :sessions
 
      def protected!
          return if authentificate?
          headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
          halt 401, "Not authorized\n"
      end

      def authentificate?
          @auth ||= Rack::Auth::Basic::Request.new(request.env)
          @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'admin']
      end

  # Before Filter
  before do
      session['counter'] ||= 0
      session['counter'] += 1
      @counter = session['counter']
  end

  get '/index.html' do
      erb :index
  end

  get '/' do
     erb :index
  end

  get '/contact.html' do
     @satz = "Fragen? Schreiben Sie uns!"
     erb :contact
   end
 
  post '/contact' do
      contactpost = ContactRequest.new(:name => params[:name], :email => params[:email], :message => params[:message])
      
      if contactpost.save
        status 201
        redirect '/contact/' + contactpost.id.to_s
      else
        redirect '/contact.html'
      end
  end

  get '/contact/:id' do
     @contactpost = ContactRequest.get(params[:id])
     erb :zeigen
  end

  get '/imprint.html' do
     @satz = "Unsere Adresse"
     erb :imprint	
   end

   get '/admin.html' do
      protected!
      erb :admin
  end

  get '/admin/contact-requests.html' do
       @contactpost = ContactRequest.all
       erb :'/contact-requests'
  end



 get '/admin/contact-requests/:id.html' do
     @contactpost = ContactRequest.get(params[:id])
     erb :form
  end      


  # Update ( edit.html )
  get '/admin/contact-requests/:id/edit.html' do 
      @contactpost = ContactRequest.get(params[:id])
      erb :edit     
  end

  post '/admin/contact-requests/:id' do
      @contactpost = ContactRequest.get(params[:id])
      @contactpost.name = (params[:name])
      @contactpost.email = (params[:email])
      @contactpost.message = (params[:message])
      @contactpost.save
      redirect "/admin/contact-requests/#{@contactpost.id}.html"
  end

  # Delete
  get '/admin/contact-requests/:id' do |id|
     #contactpost.destroy
     ContactRequest.get(id).destroy
     redirect '/admin/contact-requests.html'
  end

  # Read
 # delete '/admin/contact-requests/:id' do |id|
      #contactpost = ContactRequest.new(params[:contactpost]) 
  #    @contactpost = ContactRequest.get(id)    #find(id)
      #@contactpost = ContactRequest.get(params[:id])
      
  #   ContactRequest.get(id).destroy
  #   redirect '/admin/contact-requests.html'
  #end 


  # start the server if ruby file executed directly
  run! if app_file == $0
end
