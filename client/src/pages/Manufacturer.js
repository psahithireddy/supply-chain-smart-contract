import { useContext, useState, useEffect } from "react";
import { UserContext } from "../App";

export default function Manufacturer() {
  const Web3 = require("web3");
  const { blockchain } = useContext(UserContext);
  const [wheel_sup, set_wheel_sup] = useState(0);
  const [body_sup, set_body_sup] = useState(0);
  const [ID, setID] = useState(0);
  const [wheel_sup_auction_state, setWAucState] = useState("loading...");
  const [body_sup_auction_state, setBAucState] = useState("loading...");
  const [wheel_quantity, setWheelQuantity] = useState(0); //should get it from new func?how much quantity does supplier have
  const [body_quantity, setBodyQuantity] = useState(0);
  const [bidto_supID, setSupID_toBid] = useState(0);
  const [quant_toBid, setquant_toBid] = useState(0);
  const [blindkey, setBlindkey] = useState(0);
  const [Bid, setBid] = useState(0);
  const [partType, setPartType] = useState("Wheels");
  const [cars_available, setCars] = useState(0);
  const [reveal_price, setRevealPrice] = useState(0);
  const [reveal_quantity, setRevealQuantity] = useState(0);
  const [reveal_blindkey, setRevealBlindkey] = useState(0);
  const [reveal_to_supplier, setRevealtoSupplier] = useState(0);
  const [carsprice, setcarsprice] = useState(0);

  const init = async () => {
    let temp = [];
    temp = await blockchain.contract.methods
      .getManufacturerID(blockchain.userAccount)
      .call(); //gets all data
    console.log(temp);
    console.log(temp[0], temp[1], temp[3]);
    setID(temp[0]);
    set_wheel_sup(temp[1]);
    setWheelQuantity(temp[2]);
    set_body_sup(temp[3]);
    setBodyQuantity(temp[4]);
    setCars(temp[5]);
    console.log("wheel sup:", temp[1]);

    let temp1 = await blockchain.contract.methods
      .getAuctionState(temp[1])
      .call();

    if (temp1 == 1) setWAucState("NOT_RUNNING");
    else if (temp1 == 2) setWAucState("BIDDING");
    else if (temp1 == 3) setWAucState("REVEALING");
    console.log("wheel sup auction state:", wheel_sup_auction_state);
    console.log("body sup:", temp[3]);

    let temp2 = await blockchain.contract.methods
      .getAuctionState(temp[3])
      .call();
    if (temp2 == 1) setBAucState("NOT_RUNNING");
    else if (temp2 == 2) setBAucState("BIDDING");
    else if (temp2 == 3) setBAucState("REVEALING");
    console.log("body_sup_auction_state:", body_sup_auction_state);
  };

  const refresh = async () => {
    setBid(0);
    setBlindkey(0);
    setquant_toBid(0);
    setSupID_toBid(0);
    setPartType(0);
  };

  useEffect(() => {
    init();
  }, [blockchain]);

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        flex: "1",
      }}
    >
      <h1 style={{display: "flex", placeContent: "center", borderBottom: "1px solid black"}}>Manufacturer Homepage</h1>
      <table class="table table-striped" >
        <thead>
          <tr>
            <th scope="col">Cars</th>
            <th scope="col">Bodies</th>
            <th scope="col">Wheels</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <th>{cars_available}</th>
            <th>{body_quantity}</th>
            <th>{wheel_quantity}</th>
          </tr>
        </tbody>
      </table>

      <div style={{display: "flex", flex: 1}}>
        <div style={{display: "flex", flexDirection: "column",height: "100%",border: "1px solid black", width: "33%" }}>
          <h2 style={{display: "flex", placeContent: "center"}}>Bidding Form</h2>
          <form
          style={{
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-around",
            alignItems: "center",
            height: "100%",
          }}
        >
          
          <div class="form-group">
          <label>Part Type</label>
      
          <div class="custom-control custom-radio">
            <input
              type="radio"
              value="Body"
              class="custom-control-input"
              checked={partType === "Body"}
              onChange={(e) => setPartType(e.target.value)}
            />
            <label class="custom-control-label">Body</label>
           </div>
           <div class="custom-control custom-radio">
            <input
              type="radio"
              value="Wheels"
              class="custom-control-input"
              checked={partType === "Wheels"}
              onChange={(e) => setPartType(e.target.value)}
            />
            <label class="custom-control-label">Wheels</label>
          </div>
        </div>
          <div className="form-group">
            <label>Supplier ID</label>
            <input
              type="number"
              value={bidto_supID}
              className="form-control"
              onChange={(e) => setSupID_toBid(e.target.value)}
            />
          </div>
          <div className="form-group">
            <label>Bid Price</label>
            <input
              type="number"
              value={Bid}
              className="form-control"
              onChange={(e) => setBid(parseInt(e.target.value))}
            />
          </div>
          <div className="form-group">
            <label>quantity</label>
            <input
              type="number"
              value={quant_toBid}
              className="form-control"
              onChange={(e) => setquant_toBid(parseInt(e.target.value))}
            />
          </div>

          <div className="form-group">
            <label>Blind key</label>
            <input
              type="number"
              value={blindkey}
              className="form-control"
              onChange={(e) => setBlindkey(parseInt(e.target.value))}
            />
          </div>
          <button
            type="button"
            className="btn btn-primary"
            onClick={async () => {
              console.log("PLACING THE BID");
              console.log("Price", Bid);
              console.log("Quantity", quant_toBid);
              console.log("Key", blindkey);
              if (partType == "Body" && body_sup_auction_state == "BIDDING") {
                // if (quant_toBid > wheel_quantity) {
                //   alert(
                //     "You don't have enough wheel quantity, buy wheels first"
                //   );
                // } else {
                console.log("Blind Bid", Bid + blindkey);
                console.log("Blind Quant", quant_toBid + blindkey);
                try {
                  await blockchain.contract.methods
                    .manufacturerPlacesBid(
                      ID,
                      bidto_supID,
                      Web3.utils.soliditySha3(Bid + blindkey),
                      Web3.utils.soliditySha3(quant_toBid + blindkey),
                      Web3.utils.soliditySha3(blindkey)
                    )
                    .send({
                      value: Bid * quant_toBid * 10000000000,
                      from: blockchain.userAccount,
                    });
                  alert("Bidding for bodies successful");
                } catch (error) {
                  console.log(error);
                  alert("Error bidding");
                }
              } else if (
                partType == "Wheels" &&
                wheel_sup_auction_state == "BIDDING"
              ) {
                console.log("Blind Bid", Bid + blindkey);
                console.log("Blind Quant", quant_toBid + blindkey);
                try {
                  await blockchain.contract.methods
                    .manufacturerPlacesBid(
                      ID,
                      bidto_supID,
                      Web3.utils.soliditySha3(Bid + blindkey),
                      Web3.utils.soliditySha3(quant_toBid + blindkey),
                      Web3.utils.soliditySha3(blindkey)
                    )
                    .send({
                      value: Bid * quant_toBid * 100000000000,
                      from: blockchain.userAccount,
                    });
                  alert("Bidding for wheels successful");
                } catch (error) {
                  console.log(error);
                  alert("Error bidding");
                }
              } else {
                alert("Auction not running");
                refresh();
              }
            }}
          >
            Submit
          </button>
          </form>
        </div>
        <div style={{display: "flex", flexDirection: "column",height: "100%",border: "1px solid black", width: "34%"}}>
        <h2 style={{display: "flex", placeContent: "center"}}>Reveal Form</h2>
        <form
        style={{
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-around",
          alignItems: "center",
          height: "100%",
         
        }}>
                
                <div className="form-group">
                  <lable>Reveal to supplier</lable>
                  <input
                    className="form-control"
                    type="number"
                    value={reveal_to_supplier}
                    onChange={(e) => setRevealtoSupplier(e.target.value)}
                  />
                </div>
                <div className="form-group">
                  <label>Bid Price</label>
                  <input
                    type="number"
                    className="form-control"
                    value={reveal_price}
                    onChange={(e) => setRevealPrice(e.target.value)}
                  />
                </div>
                <div className="form-group">
                  <label>Quantity</label>
                  <input
                    type="number"
                    className="form-control"
                    value={reveal_quantity}
                    onChange={(e) => setRevealQuantity(e.target.value)}
                  />
                </div>
                <div className="form-group">
                  <label>Blind key</label>
                  <input
                    className="form-control"
                    type="number"
                    value={reveal_blindkey}
                    onChange={(e) => setRevealBlindkey(e.target.value)}
                  />
                </div>
              
              <button
                type="button"
                className="btn btn-primary"
                onClick={async () => {
                  if (
                    wheel_sup_auction_state == "REVEALING" ||
                    body_sup_auction_state == "REVEALING"
                  ) {
                    console.log("ID", ID);
                    console.log("reveal_to_supplier", reveal_to_supplier);
                    console.log("reveal_quantity", reveal_quantity);
                    console.log("Revealed price", reveal_price);
                    console.log("reveal_blindkey", reveal_blindkey);
                    try {
                      await blockchain.contract.methods
                        .manufacturerRevealsBid(
                          ID,
                          reveal_to_supplier,
                          reveal_price,
                          reveal_quantity,
                          reveal_blindkey
                        )
                        .send({ from: blockchain.userAccount });
                    } catch (error) {
                      console.log(error);
                      alert("Something went wrong!");
                    }
                  } else {
                    alert("Auction not running");
                  }
                }}
              >
                Reveal
              </button>
              </form>
        </div>
        <div style={{display: "flex", flexDirection: "column",height: "100%",border: "1px solid black", width: "33%"}}>
        <h2 style={{display: "flex", placeContent: "center"}}>Supplier's Details</h2>
        <table className="table table-striped">
          <thead>
            <tr>
              <th>Tag</th>
              <th>Part Type </th>
              <th>Auction_state</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>{wheel_sup}</td>
              <td>"Wheel"</td>
              <td> {wheel_sup_auction_state}</td>
            </tr>
            <tr>
              <td>{body_sup}</td>
              <td>"Body"</td>
              <td> {body_sup_auction_state}</td>
            </tr>
          </tbody>
        </table>
        <button
                  type="button"
                  className="btn btn-primary"
                  onClick={async () => {
                    window.location.reload();
                  }}
                >
                  Refresh
                </button>
        </div>
      </div>
      
      
  
      {/* <div style={{ display: "flex", height: "100%" }}>
        <form
          style={{
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-around",
            alignItems: "center",
            height: "100%",
            width: "40%",
          }}
        >
          <h4>Bidding Form</h4>
          <label>
            Part Type:
            <div>
              <input
                type="radio"
                value="Body"
                checked={partType === "Body"}
                onChange={(e) => setPartType(e.target.value)}
              />{" "}
              Body
              <input
                type="radio"
                value="Wheels"
                checked={partType === "Wheels"}
                onChange={(e) => setPartType(e.target.value)}
              />{" "}
              Wheels
            </div>
          </label>
          <label>
            Supplier ID:
            <input
              type="number"
              value={bidto_supID}
              onChange={(e) => setSupID_toBid(e.target.value)}
            />
          </label>
          <label>
            Bid Price:
            <input
              type="number"
              value={Bid}
              onChange={(e) => setBid(parseInt(e.target.value))}
            />
          </label>
          <label>
            quantity:
            <input
              type="number"
              value={quant_toBid}
              onChange={(e) => setquant_toBid(parseInt(e.target.value))}
            />
          </label>

          <label>
            Blind key:
            <input
              type="number"
              value={blindkey}
              onChange={(e) => setBlindkey(parseInt(e.target.value))}
            />
          </label>
          <button
            type="button"
            onClick={async () => {
              console.log("PLACING THE BID");
              console.log("Price", Bid);
              console.log("Quantity", quant_toBid);
              console.log("Key", blindkey);
              if (partType == "Body" && body_sup_auction_state == "BIDDING") {
                // if (quant_toBid > wheel_quantity) {
                //   alert(
                //     "You don't have enough wheel quantity, buy wheels first"
                //   );
                // } else {
                console.log("Blind Bid", Bid + blindkey);
                console.log("Blind Quant", quant_toBid + blindkey);
                try {
                  await blockchain.contract.methods
                    .manufacturerPlacesBid(
                      ID,
                      bidto_supID,
                      Web3.utils.soliditySha3(Bid + blindkey),
                      Web3.utils.soliditySha3(quant_toBid + blindkey),
                      Web3.utils.soliditySha3(blindkey)
                    )
                    .send({
                      value: Bid * quant_toBid * 10000000000,
                      from: blockchain.userAccount,
                    });
                  alert("Bidding for bodies successful");
                } catch (error) {
                  console.log(error);
                  alert("Error bidding");
                }
              } else if (
                partType == "Wheels" &&
                wheel_sup_auction_state == "BIDDING"
              ) {
                console.log("Blind Bid", Bid + blindkey);
                console.log("Blind Quant", quant_toBid + blindkey);
                try {
                  await blockchain.contract.methods
                    .manufacturerPlacesBid(
                      ID,
                      bidto_supID,
                      Web3.utils.soliditySha3(Bid + blindkey),
                      Web3.utils.soliditySha3(quant_toBid + blindkey),
                      Web3.utils.soliditySha3(blindkey)
                    )
                    .send({
                      value: Bid * quant_toBid * 100000000000,
                      from: blockchain.userAccount,
                    });
                  alert("Bidding for wheels successful");
                } catch (error) {
                  console.log(error);
                  alert("Error bidding");
                }
              } else {
                alert("Auction not running");
                refresh();
              }
            }}
          >
            Submit
          </button>
          <h4>
            <div>
              <form>
                Reveal Form
                <label>
                  Reveal to supplier:
                  <input
                    type="number"
                    value={reveal_to_supplier}
                    onChange={(e) => setRevealtoSupplier(e.target.value)}
                  />
                </label>
                <label>
                  Bid Price:
                  <input
                    type="number"
                    value={reveal_price}
                    onChange={(e) => setRevealPrice(e.target.value)}
                  />
                </label>
                <label>
                  Quantity:
                  <input
                    type="number"
                    value={reveal_quantity}
                    onChange={(e) => setRevealQuantity(e.target.value)}
                  />
                </label>
                <label>
                  Blind key:
                  <input
                    type="number"
                    value={reveal_blindkey}
                    onChange={(e) => setRevealBlindkey(e.target.value)}
                  />
                </label>
              </form>
              <button
                type="button"
                onClick={async () => {
                  if (
                    wheel_sup_auction_state == "REVEALING" ||
                    body_sup_auction_state == "REVEALING"
                  ) {
                    console.log("ID", ID);
                    console.log("reveal_to_supplier", reveal_to_supplier);
                    console.log("reveal_quantity", reveal_quantity);
                    console.log("Revealed price", reveal_price);
                    console.log("reveal_blindkey", reveal_blindkey);
                    try {
                      await blockchain.contract.methods
                        .manufacturerRevealsBid(
                          ID,
                          reveal_to_supplier,
                          reveal_price,
                          reveal_quantity,
                          reveal_blindkey
                        )
                        .send({ from: blockchain.userAccount });
                    } catch (error) {
                      console.log(error);
                      alert("Something went wrong!");
                    }
                  } else {
                    alert("Auction not running");
                  }
                }}
              >
                Reveal
              </button>
            </div>
          </h4>
        </form>

        <table>
          <thead>Suppliers Details</thead>
          <thead>
            <tr>
              <th>Tag</th>
              <th>Part Type </th>
              <th>Auction_state</th>
              <th>
                <button
                  type="button"
                  onClick={async () => {
                    window.location.reload();
                  }}
                >
                  Refresh
                </button>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>{wheel_sup}</td>
              <td>"Wheel"</td>
              <td> {wheel_sup_auction_state}</td>
            </tr>
            <tr>
              <td>{body_sup}</td>
              <td>"Body"</td>
              <td> {body_sup_auction_state}</td>
            </tr>
          </tbody>
        </table>
      </div> */}
    </div>
  );
}
