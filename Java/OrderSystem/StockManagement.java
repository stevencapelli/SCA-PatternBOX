package SkeletonCodeJava;

//@Service(ProductEntry.class)
public class StockManagement implements ProductEntry {
	
  //@Reference
  protected PersistenceService persistenceService;
  public StockManagement(){
	  super();
  }
  
  public boolean productEntry(int productID, int qtyProduct){
	  /*
	    * update Object is used to update data
	    */
	   Object update=""; 
	   return persistenceService.updateData(update);
  }
}
