/* Service interface */
module InvoiceAllOrNoneService
import STDL/StandardLibrary
import Order //Interface of the Order data type
export *

signature:

domain InvoiceAllOrNoneService subsetof Agent

out invoiceAllOrNoneService: Prod(Agent, Product) ->   Powerset(Order)
definitions: