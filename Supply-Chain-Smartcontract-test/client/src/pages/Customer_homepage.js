import { useContext, useState, useEffect } from "react";
import { UserContext } from "../App";

export default function Customer_homepage() {
   const { blockchain } = useContext(UserContext);
   const [manf_addr, set_manf_addr] = useState("");
   const  [ID, setID] = useState(0);
   const [manf_ID, set_manf_ID] = useState(0);
   const [price_paying, set_price_paying] = useState(0);
   const [quant_needed, set_quant_needed] = useState(0);
   const [cars_available, set_cars_available] = useState(0);
   const [cars_price, set_cars_price] = useState(0);
   const [cars_details, set_cars_details] = useState([]);
   const get_manufacturer_details = async () => {
    try{
      let temp = await blockchain.contract.methods
         .getManufacturerID(manf_addr)
         .call();

      set_manf_ID(temp[0]);
      console.log("ID: ", temp);
      set_cars_available(temp[5]);
      set_cars_price(temp[6]);
    }catch(error)
    {
      console.log(error)
    }
   }
  const init = async () => {
  let temp = await blockchain.contract.methods
          .getCustomerID(blockchain.userAccount)
          .call();
        setID(temp);
        console.log("ID: ", temp);
  };
  const verifycars = async () => {
    let idx = await blockchain.contract.methods.numberOfCarsBought(ID).call();
    console.log("idx: ", idx);
    for (let i = 0; i < idx; i++) {
      let temp = await blockchain.contract.methods
        .verifyCar(ID, i)
        .call();
      console.log("car details: ", temp);
      set_cars_details((cars_details) => [...cars_details, temp]);
    }
   }

   useEffect(() => {
      init();
    }, [blockchain]);

  return (
    <div  style={{
      display: "flex",
      flexDirection: "column",
      flex: "1",
    }}>
      <h1 style={{display: "flex", placeContent: "center"}}>Customer Homepage</h1>
      <div style={{display: "flex", flex: 1}}>
        <div style={{display: "flex", flexDirection: "column",height: "100%",border: "1px solid black", width: "33%"}}>
          <h2 style={{display: "flex", placeContent: "center"}}>Get Manufacturer Details</h2>
          <form>
          <div className="form-group">
            <label>Enter manufacturer Address</label>
            <input
              type="string" //to be changed to address, nope works
              value={manf_addr}
              className="form-control"
              onChange={(e) => set_manf_addr(e.target.value)}
            />
          </div>
          <button
            type="button"
            className="btn btn-primary"
            onClick={async () => {
              get_manufacturer_details();
            }}
          >
            Get Details
          </button>
        </form>
        <table class="table table-striped">
          <thead>Details</thead>
          <thead>
            <tr>
              <th>Manufacturer ID</th>
              <th>Cars Available</th>
              <th>Cars Price</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>{manf_ID}</td>
              <td>{cars_available}</td>
              <td> {cars_price}</td>
            </tr>
          </tbody>
        </table>
        </div>
        <div style={{display: "flex", flexDirection: "column",height: "100%",border: "1px solid black", width: "34%"}}>
          <h2 style={{display: "flex", placeContent: "center"}}>Purchase Form</h2>
          <form>
          <div className="form-group">
            <label>Enter Manufacturer ID</label>
            <input
              className="form-control"
              type="number"
              value={manf_ID}
              onChange={(e) => set_manf_ID(e.target.value)}
            />
          </div>
          <div className="form-group">
            <label>Enter Quantity</label>
            <input
              className="form-control"
              type="number"
              value={quant_needed}
              onChange={(e) => set_quant_needed(e.target.value)}
            />
          </div>
          <div className="form-group">
            <label>Enter Price</label>
            <input
              className="form-control"
              type="number"
              value={price_paying}
              onChange={(e) => set_price_paying(parseInt(e.target.value))}
            />
          </div>
          <button
            type="button"
            className="btn btn-primary"
            onClick={async () => {
              try {
                await blockchain.contract.methods
                  .customerBuysCar(ID, manf_ID, price_paying, quant_needed)
                  .send({ value: price_paying*100000000,from: blockchain.account });
              } catch (err) {
                console.log(err);
                alert("Error in making purchase");
              }
            }}
          >
            Make Purchase
          </button>
          </form>
        </div>
        <div style={{display: "flex", flexDirection: "column",height: "100%",border: "1px solid black", width:"33%"}}>
          <h2 style={{display: "flex", placeContent: "center"}}>Verify Car</h2>
          <button
            type="button"
            className="btn btn-primary"
            onClick={async () => {
              verifycars();
            }}
          >
            verify
          </button>
          <table className="table table-stripped">
          <thead>
            <tr>
              <th>Car ID</th>
              <th>Manufacturer ID</th>
              <th>Wheel Supplier ID</th>
              <th>Body Supplier ID</th>
            </tr>
          </thead>
          <tbody>
            {cars_details.map((cars) => (
              <tr key={cars.id}>
                <td>{cars.id}</td>
                <td> {cars.manufacturerID}</td>
                <td>{cars.wheelSupplier}</td>
                <td> {cars.bodySupplier}</td>
              </tr>
            ))}
          </tbody>
        </table>
        </div>
      </div>
      {/* <h3>Get Manufacturer Details</h3>
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-around",
          alignItems: "center",
          height: "20%",
          width: "40%",
        }}
      >
        <form>
          <label>
            Enter manufacturer Address: :
            <input
              type="string" //to be changed to address, nope works
              value={manf_addr}
              onChange={(e) => set_manf_addr(e.target.value)}
            />
          </label>
          <button
            type="button"
            onClick={async () => {
              get_manufacturer_details();
            }}
          >
            Get Details
          </button>
        </form>
      </div>
      <div>
        <table>
          <thead>Suppliers Details</thead>
          <thead>
            <tr>
              <th>Manufacturer ID</th>
              <th>Cars Available</th>
              <th>Cars Price</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>{manf_ID}</td>
              <td>{cars_available}</td>
              <td> {cars_price}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div>
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
          <h4>Make a purchase </h4>
          <label>
            Enter Manufacturer ID:
            <input
              type="number"
              value={manf_ID}
              onChange={(e) => set_manf_ID(e.target.value)}
            />
          </label>
          <label>
            Enter Quantity:
            <input
              type="number"
              value={quant_needed}
              onChange={(e) => set_quant_needed(e.target.value)}
            />
          </label>
          <label>
            Enter Price:
            <input
              type="number"
              value={price_paying}
              onChange={(e) => set_price_paying(parseInt(e.target.value))}
            />
          </label>
          <button
            type="button"
            onClick={async () => {
              try {
                await blockchain.contract.methods
                  .customerBuysCar(ID, manf_ID, price_paying, quant_needed)
                  .send({ value: price_paying*100000000,from: blockchain.account });
              } catch (err) {
                console.log(err);
                alert("Error in making purchase");
              }
            }}
          >
            Make Purchase
          </button>
        </form>
      </div>
      <div>
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
          <h4>Verify the Cars </h4>
          <button
            type="button"
            onClick={async () => {
              verifycars();
            }}
          >
            verify
          </button>
        </form>
      </div>
      <div>
        <table>
          <thead>
            <tr>
              <th>Car ID</th>
              <th>Manufacturer ID</th>
              <th>Wheel Supplier ID</th>
              <th>Body Supplier ID</th>
            </tr>
          </thead>
          <tbody>
            {cars_details.map((cars) => (
              <tr key={cars.id}>
                <td>{cars.id}</td>
                <td> {cars.manufacturerID}</td>
                <td>{cars.wheelSupplier}</td>
                <td> {cars.bodySupplier}</td>
              </tr>
            ))}
          </tbody>
        </table> */}
      {/* </div> */}
    </div>
  );

}
