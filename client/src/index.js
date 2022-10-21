import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import "./index.css";
import App from "./App";
import Supplier from "./pages/Supplier";
import Manufacturer from "./pages/Manufacturer";
import RegManufacturer from "./pages/RegManufacturer";
import RegSupplier from "./pages/RegSupplier";
import Assign from "./pages/Assign";
import Customer_homepage from "./pages/Customer_homepage";
import reportWebVitals from "./reportWebVitals";
import RegCustomer from "./pages/Regcust";
const root = ReactDOM.createRoot(document.getElementById("root"));
root.render(
  <BrowserRouter>
    <Routes>
      <Route path="/" element={<App />}>
        <Route path="homeSup" element={<Supplier />} />
        <Route path="homeManf" element={<Manufacturer />} />
        <Route path="homeCust" element={<Customer_homepage />} />

        <Route path="assign" element={<Assign />}>
          <Route path="regManf" element={<RegManufacturer />} />
          <Route path="regSup" element={<RegSupplier />} />
          <Route path="regCust" element={<RegCustomer />} />
        </Route>
      </Route>
    </Routes>
  </BrowserRouter>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
