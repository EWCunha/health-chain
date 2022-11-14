import React, { useEffect, useState } from 'react'
import {
    Card, Button, Typography, Box, Grid,
    FormControl, Select, MenuItem
} from '@mui/material'
import { getWeb3, getManagementContract, uploadToIPFS } from '../utils'
const AES = require("crypto-js/aes");



const Patient = () => {
    const [connString, setConnString] = useState("Connect")
    const [wallet, setWallet] = useState(undefined)
    const [patientFile, setPatientFile] = useState(undefined)
    const [specialty, setSpecialty] = useState(1)
    const [fileButtonStr, setFileButtonStr] = useState("Upload File")

    const handleChange = (evt) => {
        setSpecialty(evt.target.value)
    }

    const handleFile = (evt) => {
        setPatientFile(evt.target.files[0])
        if (evt.target.value) {
            setFileButtonStr(evt.target.files[0].name)
        } else {
            setFileButtonStr("Upload File")
        }
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
        const CID = await uploadToIPFS(patientFile)
        const managementContract = getManagementContract(wallet.signer)
        const patientAddress = await wallet.signer.getAddress()

        const encrypted = AES.encrypt(CID, patientAddress);

        const tx = await managementContract.deployHistory(encrypted.toString(), specialty)
        await tx.wait()
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
                        Medical History
                    </Typography>
                    <Typography variant="h6" color="text.secondary">

                    </Typography>
                    <FormControl sx={{ m: 1, minWidth: 500 }}>
                        <Button
                            variant="contained"
                            component="label"
                        >
                            {fileButtonStr}
                            <input
                                type="file"
                                hidden
                                onChange={handleFile}
                            />
                        </Button>

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
                            disabled={!(wallet && patientFile) ? true : false}
                        >
                            Submit
                        </Button>
                    </FormControl>
                </Card>
            </Box>
        </Grid>
    )
}

export default Patient