import { useContext, useState, useEffect } from "react";
import { UserContext } from "../App";

export default function Supplier() {
  const { blockchain } = useContext(UserContext);
  const { isSupplier } = useContext(UserContext);
  const [auction_state, setAucState] = useState("loading...");
  const [ID, setID] = useState(0);
  const [bid_details, setBidDetails] = useState([]);

  const init = async () => {
    let temp = await blockchain.contract.methods
      .getSupplierID(blockchain.userAccount)
      .call();
    setID(temp);
    console.log("ID: ", temp);

    console.log("ID:", ID);
    let temp1 = await blockchain.contract.methods.getAuctionState(temp).call();
    if (temp1 == 1) setAucState("NOT_RUNNING");
    else if (temp1 == 2) setAucState("BIDDING");
    else if (temp1 == 3) setAucState("REVEALING");
    console.log(temp1);
  };

  const getallbids = async () => {
    let temp = await blockchain.contract.methods
      .getNumberOfBids(blockchain.userAccount)
      .call();
    console.log("bid length: ", temp);
    let bids = [];
    for (let i = 0; i < temp; i++) {
      let here = await blockchain.contract.methods
        .getSupplierBids(blockchain.userAccount, i)
        .call();
      console.log(here);
      bids.push(here);
    }
    setBidDetails(bids);
    console.log(bids);
    
  };

  useEffect(() => {
    init();
    getallbids();
  }, [blockchain]);

  return (
    <div>
      <h1>Welcome Supplier!</h1>
      <h1>{isSupplier ? "true" : "false"}</h1>
      <h1> Current State of Auction is {auction_state}</h1>
      <h2>
        {auction_state == "NOT_RUNNING" ? (
          <button
            type="button"
            onClick={async () => {
              try {
                await blockchain.contract.methods
                  .supplierStartBidding(ID)
                  .send({ from: blockchain.userAccount });
                init();
              } catch (error) {
                alert("Something went wrong!"); //has error here
              }
            }}
          >
            {" "}
            Start Auction
          </button>
        ) : (
          ""
        )}
      </h2>
      <h4>
        {auction_state == "BIDDING" ? (
          <div>
            <table>
              <thead>
                <th>buyerid</th>
                <th>blind price</th>
                <th></th>
                <th>blind quantity</th>
              </thead>
              <tbody>
                {bid_details.map((bid) => (
                  <tr>
                    <td>{bid[2]}</td>
                    <td>{bid[0]}</td>
                    <td> </td>
                    <td>{bid[1]}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            <button
              type="button"
              onClick={async () => {
                try {
                  await blockchain.contract.methods
                    .supplierStartReveal(ID)
                    .send({ from: blockchain.userAccount });
                  init();
                } catch (error) {
                  alert("Something went wrong!"); //has error here
                }
              }}
            >
              Stop bids and start reveal phase
            </button>
          </div>
        ) : (
          ""
        )}
      </h4>
      <h2>
        {auction_state == "REVEALING" ? (
          <div>
            <table>
              <thead>
                <th>buyerid</th>
                <th>blind price</th>
                <th></th>
                <th>Revealed Bid</th>
              </thead>
              <tbody>
                {bid_details.map((bid) => (
                  <tr>
                    <td>{bid[2]}</td>
                    <td>{bid[0]}</td>
                    <td> </td>
                    <td>{bid[3]?'true':'false'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            <button
              type="button"
              onClick={async () => {
                try {
                  await blockchain.contract.methods
                    .supplierEndAuction(ID)
                    .send({ from: blockchain.userAccount });
                  init();
                } catch (error) {
                  alert(error);
                }
              }}
            >
              End Reveal Phase
            </button>
          </div>
        ) : (
          ""
        )}
      </h2>
    </div>
  );
}
