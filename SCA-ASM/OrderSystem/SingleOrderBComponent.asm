asm SingleOrderBComponent
import STDL/StandardLibrary
import STDL/CommonBehavior
import InvoiceSingleOrderService	
signature:
      	//@Backref
	shared client: Agent -> Agent

        // orders to invoice
	controlled orders: Agent -> Powerset(Order)
	
definitions:

	
	macro rule r_DeleteStock($p in Product ,$q in Natural) = 
		stockQuantity($p):= stockQuantity($p) - $q
	

//Per step at most one order is invoiced, with an unspecified schedule
//(thus also not taking into account any arrival time of orders) and with an abstract deletion function.
//@Service  Invoice an order at a time.
       rule r_invoiceSingleOrder($a in Agent, $orders in  Powerset(Order)) = 	
		choose $order in orders with orderState($order) = PENDING do
			if(orderQuantity($order) <= stockQuantity(referencedProduct($order))) then
				par
				    orderState($order) := INVOICED 
				    r_DeleteStock[referencedProduct($order),orderQuantity($order)] 
				    invoiceSingleOrder(self,orders(self)) := $order //setting of the out business function location with the order to invoice 
				endpar
			endif
   	
        rule r_SingleOrderBComponent = 
        if nextRequest(self)="r_invoiceSingleOrder(Agent, Powerset(Order))"  then 
	 seq
		r_wreceive[client(self),"r_invoiceSingleOrder(Agent, Powerset(Order))",orders(self)]
		if (isDef(orders(self))) then
		  r_invoiceSingleOrder[self,orders(self)] //direct service invocation
		endif
		r_wreply[client(self),"r_invoiceSingleOrder(Agent, Powerset(Order))",invoiceSingleOrder(self,orders(self))]
	endseq
        endif
   
rule r_init($a in InvoiceSingleOrderService) =
 status($a):=READY
