package SkeletonCodeJava;

import java.util.ArrayList;
import java.util.List;

public class InvoicingManagement {
  //@Reference
  protected QueryService queryService;
  //@Reference
  protected PersistenceService persistenceService;
  //@Reference
  protected InvoiceSingleService singleService;
//@Reference
  protected InvoiceAllOrNoneService allOrNone;
//@Reference
  protected InvoiceMaxOrdersService maxOrders;
//@Reference
  protected InvoiceOrdersService orders;
  //@Property
  private String orderPolicy;
  
  
  public InvoicingManagement(){
	  super();
  }
  
  private void invoced(){
	  /*
	   * doInvoice select orders state in invoicing
	   */
	  Object order=selectOrders();
	  List<Object> orders=new ArrayList<Object>();
	  orders.add(order);
	  manegeOrder(orders);
	  Object update="";
	  persistenceService.updateData(update);
	  
  }
  
  private void manegeOrder(List<Object> orders){
	  switch(this.orderPolicy){
	  case "single-order":{
		  this.singleService.invoiceSingleService(orders);
		  break;
	  }
	  case "all-or-none":{
		  this.allOrNone.invoiceAllOrNoneService(orders);
		  break;
	  }
	  case "max-orders":{
		  this.maxOrders.invoiceMaxOrdersService(orders);
		  break;
	  }
	  case "default":{
		  this.orders.invoiceOrdersService(orders);
		  break;
	  }
	  default:
	  }
  }
  
  private Object selectOrders(){
	  /*
	   * query Object is used to have the list of all Orders which can be invoced
	   */
	  Object query=""; 
	  Object result=queryService.executeQuery(query);
	  return selectOrders(result);
	  
  }
  
  private Object selectOrders(Object o){
	  /*
	   * to do something
	   */
	  return o;
  }
  
  public void setOrderPolicy(String s){
	  this.orderPolicy=s;
  }
  
  public String getOrderPolicy(){
	  return this.orderPolicy;
  }
   
}
