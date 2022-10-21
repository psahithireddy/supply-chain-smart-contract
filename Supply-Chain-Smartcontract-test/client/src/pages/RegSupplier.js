import { useState, useContext } from "react";
import { UserContext } from "../App";

export default function RegSupplier() {
  const [partType, setPartType] = useState("Body");
  const [quan, setQuant] = useState(0);
  const [bidderCount, setBidderCount] = useState(0);
  const { blockchain } = useContext(UserContext);
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        flex: "1",
      }}
    >
      <h1 style={{display: "flex", placeContent: "center"}}>Supplier Registration</h1>
      <form
        style={{
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-around",
          alignItems: "center",
          flex: "100%",
          border: "1px solid black"
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
        <div class="form-group">
          <label>Quantity</label>
          
          <input
            type="number"
            value={quan}
            class="form-control"
            onChange={(e) => setQuant(e.target.value)}
          />
        </div >
        <div class="form-group">
          <label>Bidder Count</label>
          <input
            type="number"
            value={bidderCount}
            class="form-control"
            onChange={(e) => setBidderCount(e.target.value)}
          />
        </div>
        <button
          type="button"
          class="btn btn-primary"
          onClick={async () => {
            try {
              await blockchain.contract.methods
                .addSupplier(
                  partType === "Body" ? 0 : 1,
                  quan,
                  blockchain.userAccount,
                  bidderCount
                )
                .send({ from: blockchain.userAccount });
              window.location.assign("/homeSup");
            } catch (error) {
              alert("Something went wrong!");
            }
          }}
        >
          Submit
        </button>
      </form>
    </div>
  );
}
