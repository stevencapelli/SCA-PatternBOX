asm AllOrNoneBComponent
import STDL/StandardLibrary
import STDL/CommonBehavior
import InvoiceMaxOrdersService	
signature:
      	//@Backref
	shared client: Agent -> Agent

        // product with orders to invoice
	controlled product: Agent -> Product
	
definitions:

	
	macro rule r_DeleteStock($p in Product ,$q in Natural) = 
		stockQuantity($p):= stockQuantity($p) - $q
	

//@Service  maximum orders for one product.
//For this rule we need to define a static function maxQuantitySubsets: Powerset(Powerset(Order))-> Powerset(Powerset(Order)) which, given a set of set of orders, returns
//the set of all the sets having a maximum quantity.
       rule r_InvoiceMaxOrders($a in Agent, $product in Product) = 	
			let ($pending = pendingOrders($product)) in
				let ($invoicablePending = {$o in $pending | totalQuantity($o) <= stockQuantity($product) : $o} ) in
					choose $orderSet in maxQuantitySubsets($invoicablePending)  do
						par
							forall $order in $orderSet  do
								orderState($order) := INVOICED 
							r_DeleteStock[$product, totalQuantity($orderSet)]
							invoiceMaxOrders(self,product(self)) := $orderSet //setting of the out business function location with the product's orders to invoice
						endpar
				endlet
			endlet
   	
        rule r_MaxOrdersBComponent = 
        if nextRequest(self)="r_invoiceMaxOrders(Agent, Product)"  then 
	 seq
		r_wreceive[client(self),"r_invoiceMaxOrders(Agent, Product)",product(self)]
		if (isDef(product(self))) then
		  r_invoiceMaxOrders[self,product(self)] //direct service invocation
		endif
		r_wreply[client(self),"r_invoiceMaxOrders(Agent, Product)",invoiceMaxOrders(self,product(self))]
	endseq
        endif
   
rule r_init($a in InvoiceMaxOrdersService) =
 status($a):=READY