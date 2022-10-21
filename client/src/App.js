import "./App.css";
import React, { useState, useEffect, createContext } from "react";
import getWeb3 from "./getWeb3";
import Contract from "./contracts/NewMarketPlace.json";
import { useNavigate, Outlet, Link } from "react-router-dom";

export const UserContext = createContext();

function App() {
  const [blockchain, setBlockchain] = useState({
    web3: null,
    accounts: null,
    contract: null,
    userAccount: null,
  });
  const [balance, setBalance] = useState(0);
  const [load, setLoad] = useState(false);
  const [isManufacturer, setIsManufacturer] = useState(false);
  const [isSupplier, setIsSupplier] = useState(false);
  const [isCustomer, setIsCustomer] = useState(false);
  const navigate = useNavigate();

  useEffect(() => {
    const init = async () => {
      try {
        // Get network provider and web3 instance.
        const web3 = await getWeb3();

        // Use web3 to get the user's accounts.
        const accounts = await web3.eth.getAccounts();

        // Get the contract instance.
        const networkId = await web3.eth.net.getId();
        const deployedNetwork = Contract.networks[networkId];

        let userAccount = await web3.eth.getCoinbase();
        const contract = new web3.eth.Contract(
          Contract.abi,
          deployedNetwork && deployedNetwork.address,
          {
            from: userAccount, // default from address
            gasPrice: "20000000000", // default gas price in wei, 20 gwei in this case
          }
        );

        // Set web3, accounts, and contract to the state, and then proceed with an
        // example of interacting with the contract's methods.
        setBlockchain({ web3, accounts, contract, userAccount });
        console.log({ web3, accounts, contract, userAccount });
        web3.eth
          .getBalance(userAccount)
          .then((currentBalance) => setBalance(currentBalance));
        setLoad(true);
        if (await contract.methods.isManufacturer().call()) {
          setIsManufacturer(true);
        } else if (await contract.methods.isSupplier().call()) {
          setIsSupplier(true);
        } else if(await contract.methods.isCustomer().call()){
          setIsCustomer(true);
        }
      } catch (error) {
        // Catch any errors for any of the above operations.
        alert(
          `Failed to load web3, accounts, or contract. Check console for details.`
        );
        console.error(error);
      }
    };
    init();
  }, [navigate]);

  window.ethereum.on("accountsChanged", function (accounts) {
    // Time to reload your interface with accounts[0]!
    window.location.assign("/");
  });

  return load ? (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        height: "100vh",
      }}
    >
      <div
        style={{
          display: "flex",
          justifyContent: "space-around",
        }}
      >
        <p>Account Id: {blockchain.userAccount}</p>
        <p>Balance: {balance}</p>
      </div>
      <nav
        style={{
          display: "flex",
          justifyContent: "space-around",
        }}
      >
        {!isSupplier && !isManufacturer && !isCustomer && <Link to="/assign">Assign</Link>}
        {isSupplier && <Link to="/homeSup">MarketPlace</Link>}
        {isManufacturer && <Link to="/homeManf">MarketPlace</Link>}
        {isCustomer && <Link to="/homeCust">MarketPlace</Link>}
      </nav>

      <UserContext.Provider
        value={{
          blockchain,
          isSupplier,
          isManufacturer,
        }}
      >
        <Outlet />
      </UserContext.Provider>
    </div>
  ) : (
    <div>Loading</div>
  );
}

export default App;
