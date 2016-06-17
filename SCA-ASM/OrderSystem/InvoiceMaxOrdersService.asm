/* Service interface */
module InvoiceMaxOrdersService
import STDL/StandardLibrary
import Order //Interface of the Order data type
export *

signature:

domain InvoiceMaxOrdersService subsetof Agent

out invoiceMaxOrders: Prod(Agent, Product) ->  Powerset(Order)
definitions: