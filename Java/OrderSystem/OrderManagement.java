package SkeletonCodeJava;

//@Service(interfaces={Store.class, SendOrder.class, CancelOrder.class})
public class OrderManagement implements Store, SendOrder, CancelOrder {
	
   //@Reference
   protected PersistenceService persistenceService;
 //@Reference
   protected QueryService queryService;
   
   public OrderManagement(){
	   super();
   }
   
   public boolean sendOrder(int refProduct, int qtyProduct, int customerID){
	   /*
	    * update Object is used to update data, put Order in state pending
	    */
	   Object update=""; 
	   return persistenceService.updateData(update);
   }
   
   public boolean cancelOrder(int orderID, int customerID){
	   /*
	    * update Object is used to update data
	    */
	   Object update=""; 
	   return persistenceService.updateData(update);
   }
   
   public Object storeService(Object o){
	   /*
	    * storeService is used to comunicate with GUI component.
	    */
	   return queryService.executeQuery(o);
   }
}
