
import './App.css';
import Header from './components/Header';
import Home from './components/Home';
import Hospital from './components/Hospital';
import Patient from './components/Patient';
import { Routes, Route } from "react-router-dom";

function App() {
  return (
    <>
      <Header />
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="hospital" element={<Hospital />} />
        <Route path="patient" element={<Patient />} />
      </Routes>
    </>
  );
}

export default App;
