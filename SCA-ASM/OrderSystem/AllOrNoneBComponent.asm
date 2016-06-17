asm AllOrNoneBComponent
import STDL/StandardLibrary
import STDL/CommonBehavior
import InvoiceAllOrNoneService	
signature:
      	//@Backref
	shared client: Agent -> Agent

        // product with orders to invoice
	controlled product: Agent -> Product
	
definitions:

	
	macro rule r_DeleteStock($p in Product ,$q in Natural) = 
		stockQuantity($p):= stockQuantity($p) - $q
	

//@Service  All orders for one product are simultaneously invoiced (or none if the stock cannot satisfy the request).
//InvoiceAllOrNone makes use of a function pendingOrders yielding the set of pending orders for a certain product, 
//and of a (static) function totalQuantity returning the total quantity of a set of orders.
       rule r_invoiceAllOrNone($a in Agent, $product in Product) = 	
        	let ( $pending = pendingOrders($product) ) in
				let ( $total = totalQuantity($pending) ) in
				   seq
					if $total > 0 and $total <= stockQuantity($product) then 
						par
							forall $order in $pending do orderState($order) := INVOICED 
							r_DeleteStock[$product, $total]
						endpar
					endif
					invoiceAllOrNone(self,product(self)) := $pending //setting of the out business function location with the product's orders to invoice
				   endseq
				endlet
		endlet
   	
        rule r_AllOrNoneBComponent = 
        if nextRequest(self)="r_invoiceAllOrNone(Agent, Powerset(Order))"  then 
	 seq
		r_wreceive[client(self),"r_invoiceAllOrNone(Agent, Powerset(Order))",product(self)]
		if (isDef(product(self))) then
		  r_invoiceSingleOrder[self,product(self)] //direct service invocation
		endif
		r_wreply[client(self),"r_invoiceAllOrNone(Agent, Powerset(Order))",invoiceAllOrNone(self,product(self))]
	endseq
        endif
   
rule r_init($a in InvoiceAllOrNoneService) =
 status($a):=READY