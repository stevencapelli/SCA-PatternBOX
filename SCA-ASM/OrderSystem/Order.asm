/* Module for the Order Data Type*/
module Order

import STDL/StandardLibrary
import Product //Interface of the Product data type
export *

//declare universes and functions
signature:

dynamic abstract domain Order
enum domain OrderStatus = {INVOICED | PENDING | CANCELLED}

controlled id: Order -> Integer
controlled details: Order -> String
controlled orderState: Order -> OrderStatus
controlled orderQuantity: Order -> Natural
controlled referencedProduct: Orders -> Product

static totalQuantity: Prod(Powerset(Order),Product) -> Natural
static invoicable: Powerset(Orders) -> Boolean
static referencedProducts: Powerset(Order) -> Powerset(Product)
static pendingOrders: Products -> Powerset(Order)
static totalQuantity: Powerset(Order) -> Natural
// returns all the posible subsets of the pending orders for a product
static maxQuantitySubsets: Powerset(Powerset(Order)) -> Powerset(Powerset(Order))


definitions:	

	function totalQuantity($so in Powerset(Order), $p in Product) =
 		if (isEmpty($so)) then 0 
		else
			if (referencedProduct(first(asSequence($so))) = $p) then 
				orderQuantity(first(asSequence($so))) + totalQuantity(excluding($so,first(asSequence($so))),$p)
			else 
				totalQuantity(excluding($so,first(asSequence($so))),$p)
			endif
	endif


       function invoicable($so in Powerset(Order)) = 
		( forall $o in $so with orderState($o) = PENDING)  
		 and 
		( forall $p in refProducts($so)  with totalQuantity(asSet($so),$p) <= stockQuantity($p))
		
       function referencedProducts($so in Powerset(Orders)) =
 		if (isEmpty($so)) then {} 
		else
			let ( $first = chooseone($so)) in
			 including(referencedProducts(excluding($so,$first)),referencedProduct($first))
			endlet
		endif	
		
	/* given a product return the set of orders of that product that are still PENDING*/	
	function pendingOrders($p in Product) = 
		{$o in Order | orderState($o) = PENDING and referencedProduct($o) = $p : $o}	
		
	/* given a set of orders, return the sum of quantity of such orders */
	function totalQuantity($so in Powerset(Order)) =
		if (isEmpty($so)) then
			0
		else
			let ( $first =  chooseone($so)) in
				( orderQuantity($first) + totalQuantity(excluding($so,$first)))
			endlet
		endif	
		
	/* given a product, return all the possible subsets of orders
	function maxQuantitySubsets($so in Powerset(Powerset(Orders))) =
	*/	
	
	
	invariant over orderQuantity: forall $o in Order with orderQuantity($o) > 0
	invariant over orderState: forall $o in Order with orderState($o) != undef