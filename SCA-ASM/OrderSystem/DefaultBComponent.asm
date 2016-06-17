asm DefaultBComponent
import STDL/StandardLibrary
import STDL/CommonBehavior
import InvoiceOrdersService	
signature:
      	//@Backref
	shared client: Agent -> Agent

        // orders to invoice
	controlled orders: Agent -> Powerset(Order)
	
definitions:

	
	macro rule r_DeleteStock($p in Product ,$q in Natural) = 
		stockQuantity($p):= stockQuantity($p) - $q
	

//The service InvoiceOrders uses a predicate invoicable that is true on a set of pending orders with enough quantity of requested
//products in the stack, and a function refProducts which yields the set of all products referenced in a set of orders.
//Note that the non-deterministic selection of the orders to invoice could be performed by a monitored function which would formalise
//the user selection of a set of orders or the results of a particular scheduling algorithm.
//@Service  Choose subset of orders
       rule r_invoiceOrders($a in Agent, $orders in  Powerset(Order)) = 	
	   choose $orderSet in Powerset($orders) with invoicable($orderSet) do
			par
				forall $order in $orderSet with true do
					orderState($order) := INVOICED 
				forall $product in referencedProducts($orderSet) with true do
					r_DeleteStock[$product, totalQuantity($orderSet,$product)]
				invoiceOrders(self,orders(self)) := $orderSet //setting of the out business function location 	
			endpar
         

   	
        rule r_DefaultBComponent = 
        if nextRequest(self)="r_invoiceOrders(Agent, Powerset(Order))"  then 
	 seq
		r_wreceive[client(self),"r_invoiceOrders(Agent, Powerset(Order))",orders(self)]
		if (isDef(orders(self))) then
		  r_invoiceOrders[self,orders(self)] //direct service invocation
		endif
		r_wreply[client(self),"r_invoiceOrders(Agent, Powerset(Order))",invoiceOrders(self,orders(self))]
	endseq
        endif
   
rule r_init($a in InvoiceOrdersService) =
 status($a):=READY
