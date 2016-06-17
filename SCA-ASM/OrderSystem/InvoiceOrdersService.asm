/* Service interface */
module InvoiceOrdersService
import STDL/StandardLibrary
import Order //Interface of the Order data type
export *

signature:

domain InvoiceOrdersService subsetof Agent

out invoiceOrders: Prod(Agent, Powerset(Order)) ->  Powerset(Order)
definitions: