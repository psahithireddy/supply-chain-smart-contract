import { useState, useContext, useEffect } from "react";
import { UserContext } from "../App";

export default function RegManufacturer() {
  const { blockchain } = useContext(UserContext);

  useEffect(() => {
    const init = async () => {
      updateSuppliers();
      // let temp = await blockchain.contract.methods.getAllSuppliers().call();
      // let temp = updateSuppliers();
      // setAllSuppliers(temp);
      // console.log(temp);
    };
    const updateSuppliers = async () => {
      let size = await blockchain.contract.methods.numSuppliers().call();
      let ret = [];
      console.log(size);
      for (let i = 1; i <= size; i++) {
        let temp = await blockchain.contract.methods.getSupplierByID(i).call();
        ret.push({
          tag: temp[0],
          partType: temp[1],
          quantityAvailable: temp[2],
          wallet: temp[3],
        });
      }
      setAllSuppliers(ret);
      console.log(ret);
    };
    init();
  }, [blockchain]);

  const [bodySup, setBodySup] = useState(0);
  const [wheelSup, setWheelSup] = useState(0);
  const [askPrice, setAskPrice] = useState(0);
  const [allSuppliers, setAllSuppliers] = useState([]);

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        flex: "1",
      }}
    >
      <h1 style={{display : "flex", justifyContent: "center", alignContent: "center"}}>Manufacturer Registration</h1>
      <div style={{ display: "flex", height: "100%" }}>
        <form
          style={{
            display: "flex",
            flexDirection: "column",
            justifyContent: "space-around",
            alignItems: "center",
            height: "100%",
            width: "50%",
            border: "1px solid black"
          }}
        >
          <div class="form-group">
            <label>Body Supplier</label>
            
            <input
              type="number"
              class="form-control"
              value={bodySup}
              onChange={(e) => setBodySup(e.target.value)}
            />
          </div>
          <div class="form-group">
            <lable>Wheel Supplier</lable>
            <input
              type="number"
              value={wheelSup}
              class="form-control"
              onChange={(e) => setWheelSup(e.target.value)}
            />
          </div>
          <div class="form-group">
            <label>Set Cars Price</label>
            <input
              type="number"
              value={askPrice}
              class="form-control"
              onChange={(e) => setAskPrice(e.target.value)}
            />
          </div>
          <button
            type="button"
            class="btn btn-primary"
            onClick={async () => {
              try {
                await blockchain.contract.methods
                  .addManufacturer(
                    blockchain.userAccount,
                    wheelSup,
                    bodySup,
                    askPrice
                  )
                  .send({ from: blockchain.userAccount });
                window.location.assign("/homeManf");
              } catch (error) {
                alert("Something went wrong!");
              }
            }}
          >
            Submit
          </button>
        </form>
        <table class="table table-striped" style={{width: "50%", border: "1px solid black", height: "100%"}}>
          <thead>
            <tr>
              <th scope="col">tag</th>
              <th scope="col">partType</th>
              <th scope="col">quantity</th>
              <th scope="col">address</th>
            </tr>
          </thead>
          <tbody>
            {allSuppliers.map((supplier) => (
              <tr key={supplier.tag}>
                <td>{supplier.tag}</td>
                <td> {supplier.partType === "1" ? "Body" : "Wheel"}</td>
                <td>{supplier.quantityAvailable}</td>
                <td> {supplier.wallet}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
