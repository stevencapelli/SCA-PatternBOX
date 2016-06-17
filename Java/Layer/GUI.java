package patternLayer;

public class GUI {
	//@Reference
	  protected ApplicationService applicationService;
	   
	  public GUI(){
		  super();
	  }
	   public void sendCommand(Object o){
		 applicationService.GUIcommand(o);
		 doSomething();
		 
	   }
	   
	   private void doSomething(){
		   /*
		    * doSomething
		    */
	   }
}
