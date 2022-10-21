import { useState, useContext } from "react";
import { UserContext } from "../App";

export default function RegSupplier() {
  const { blockchain } = useContext(UserContext);
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        flex: "1",
      }}
    >
      <h1 style={{display: "flex", placeContent: "center", borderBottom: "1px solid black"}}>Customer Registration</h1>
        <form style={{display: "flex", placeContent: "center"}}>
        <button
          type="button"
          class="btn btn-primary"
          
          onClick={async () => {
            try {
              await blockchain.contract.methods
                .addCustomer(
                  blockchain.userAccount, 
                )
                .send({ from: blockchain.userAccount });
              window.location.assign("/homeCust");
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
