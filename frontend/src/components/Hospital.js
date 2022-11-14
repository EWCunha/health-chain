import React, { useEffect, useState } from 'react'
import {
    Card, Button, Typography, Box, Grid,
    FormControl, TextField, Select, MenuItem, Chip
} from '@mui/material'
import { getWeb3, getManagementContract, getMedicalHistoryContract } from '../utils'
import { ethers } from "ethers"
const CryptoJS = require("crypto-js");

const Hospital = () => {

    const [connString, setConnString] = useState("Connect")
    const [wallet, setWallet] = useState(undefined)
    const [patientAddress, setPatientAddress] = useState(undefined)
    const [specialty, setSpecialty] = useState(1)
    const [historyURI, setHistoryURI] = useState("")

    const handleChange = (evt) => {
        setSpecialty(evt.target.value)
    }

    const handleAddress = (evt) => {
        setPatientAddress(evt.target.value)
    }

    const handleConnect = async () => {
        if (!wallet) {
            const new_wallet = await getWeb3()
            setWallet(new_wallet)
        } else {
            setWallet(undefined)
        }
    }

    const handleConnString = async () => {
        if (wallet) {
            const new_hosp_address = await wallet.signer.getAddress()
            const w_string = new_hosp_address.substr(0, 6) + "..." + new_hosp_address.substr(new_hosp_address.length - 4, new_hosp_address.length)
            setConnString(w_string)
        } else {
            setConnString("Connect")
        }
    }

    const handleSubmit = async () => {
        const isAddress = ethers.utils.isAddress(patientAddress)
        if (!isAddress) {
            alert("patient address is not valid!")
            return
        }

        const managementContract = getManagementContract(wallet.signer)
        const specialtyContractAddress = await managementContract.histories(patientAddress, specialty)
        const specialtyContract = getMedicalHistoryContract(specialtyContractAddress, wallet.signer)
        const new_historyURI = await specialtyContract.getURI()

        const hospAddress = await wallet.signer.getAddress()

        const bytes = CryptoJS.AES.decrypt(new_historyURI, hospAddress);
        const decrypted = bytes.toString(CryptoJS.enc.Utf8);

        setHistoryURI(`https://ipfs.io/ipfs/${decrypted}`)
    }

    useEffect(() => {
        handleConnString()
    }, [wallet])

    return (
        <Grid >
            <Box style={{ display: "flex", justifyContent: 'center' }}>
                <Card sx={{ alignItems: "center", display: "flex", flexDirection: "column", marginTop: 1, marginBottom: 3, padding: 3 }}>
                    <Button variant="contained" sx={{ margin: "5px" }} onClick={handleConnect}>
                        {connString}
                    </Button>
                    <Typography gutterBottom variant="h5" component="div" sx={{ fontFamily: "Nunito", }}>
                        Query
                    </Typography>
                    <Typography variant="h6" color="text.secondary">

                    </Typography>
                    <FormControl sx={{ m: 1, minWidth: 500 }}>
                        <TextField
                            id="outlined-basic"
                            label="Patient wallet address... (0x...)"
                            variant="outlined"
                            value={patientAddress}
                            onChange={handleAddress}
                            sx={{ background: "primary.main", margin: "5px" }}
                        />

                        <Select
                            labelId="specialty-select"
                            id="specialty-select-id"
                            value={specialty}
                            label="Specialty"
                            onChange={handleChange}
                            variant="outlined"
                            sx={{ margin: "5px" }}
                        >
                            <MenuItem value={1}>Cardio</MenuItem>
                            <MenuItem value={2}>Neuro</MenuItem>
                            <MenuItem value={3}>Pneumo</MenuItem>
                        </Select>

                        <Button
                            onClick={handleSubmit}
                            variant="contained"
                            sx={{ margin: "5px" }}
                            disabled={!(wallet && patientAddress) ? true : false}
                        >
                            Submit
                        </Button>
                    </FormControl>
                    {historyURI ? (
                        <Chip
                            label={historyURI}
                            color="success"
                            sx={{ m: 1, minWidth: 500 }}
                        />
                    ) : (<ins></ins>)}
                </Card>
            </Box>
        </Grid>
    )
}

export default Hospital