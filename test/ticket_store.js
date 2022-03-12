const TicketStore = artifacts.require("TicketStore");

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("TicketStore", function (accounts) {

  const price = web3.utils.toWei('0.05', 'ether')
  const value = web3.utils.toWei('0.1', 'ether')
  const nTicket = 10
  const singer = "Marco Mengoni"
  const id = 0
  const amount = 5

  let ticketStore
  const owner = accounts[0]
  const buyer = accounts[1] 

  before(async() => {
    ticketStore = await TicketStore.deployed()
  });

  it("Should create event", async() => {
    await ticketStore.createEvent(price, nTicket, singer, { from: owner })
  });

  it("Should buy a ticket", async() => {
    await ticketStore.buyEvent( id, amount, { from: buyer, value: value })
  });

});