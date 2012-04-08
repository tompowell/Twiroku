class AppointmentreminderController < ApplicationController
 
  # your Twilio authentication credentials
  ACCOUNT_SID = 'AC337666c6580d4ced9f620b4baee59f41'
  ACCOUNT_TOKEN = 'd29f1da004d3972847f92a6bf413a826'
 
  # base URL of this application
  BASE_URL = "http://localhost:3000/appointmentreminder"
 
  # Outgoing Caller ID you have previously validated with Twilio
  CALLER_ID = '13474394098'
 
  def index
  end
 
  # Use the Twilio REST API to initiate an outgoing call
  def makecall
    if !params['number']
      redirect_to :action => '.', 'msg' => 'Invalid phone number'
      return
    end
 
    # parameters sent to Twilio REST API
    data = {
      :from => CALLER_ID,
      :to => params['number'],
      :url => BASE_URL + '/reminder',
    }
 
    begin
      client = Twilio::REST::Client.new(ACCOUNT_SID, ACCOUNT_TOKEN)
      client.account.calls.create data
    rescue StandardError => bang
      redirect_to :action => '.', 'msg' => "Error #{bang}"
      return
    end
 
    redirect_to :action => '', 'msg' => "Calling #{params['number']}..."
  end

  def reminder
    @post_to = BASE_URL + '/directions'
    render :action => "reminder.xml.builder", :layout => false
  end
  
  # TwiML response that inspects the caller's menu choice:
# - says good bye and hangs up if the caller pressed 3
# - repeats the menu if caller pressed any other digit besides 2 or 3
# - says the directions if they pressed 2 and redirect back to menu
  def directions
    if params['Digits'] == '3'
      redirect_to :action => 'goodbye'
      return
    end
   
    if !params['Digits'] or params['Digits'] != '2'
      redirect_to :action => 'reminder'
      return
    end
   
    @redirect_to = BASE_URL + '/reminder'
    render :action => "directions.xml.builder", :layout => false
  end
end
