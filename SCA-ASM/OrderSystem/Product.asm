/* Module for the Product Data Type*/
module Product

import STDL/StandardLibrary
export *

//declare universes and functions
signature:

dynamic abstract domain Product
controlled id: Product -> Integer
controlled stockQuantity: Product -> Natural

definitions:

invariant over stockQuantity: forall $p in Product with stockQuantity($p)>=0