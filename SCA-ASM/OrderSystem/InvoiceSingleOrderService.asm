/* Service interface */
module InvoiceSingleOrderService

import STDL/StandardLibrary
import Order //Interface of the Order data type
export *

signature:

domain InvoiceSingleOrderService subsetof Agent

out invoiceSingleOrder: Prod(Agent, Powerset(Order)) ->  Order
definitions: