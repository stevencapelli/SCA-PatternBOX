package patternLayer;

import orderSystem.PersistenceService;
import orderSystem.QueryService;

//@Service(ApplicationService.class)
public class Application implements ApplicationService {
	//@Reference
	  protected QueryService queryService;
	//@Reference
	   protected PersistenceService persistenceService;
	   
	   public Application(){
		   super();
	   }
	   
	   public Object GUIcommand(Object o){
		   o=doSomething();
		   return storeData(o);
	   }
	   
	   private Object doSomething(){
		   /*
		    * doSomething
		    */
		   return "";
	   }
	   
	   private boolean storeData(Object o){
	     /*
	      * store data
	      */
		   persistenceService.updateData(o);
		   return true;
	   }
	   
	   private Object queryData(Object o){
		   /*
		    * query data
		    */
		   return queryService.executeQuery(o);
	   }
}
