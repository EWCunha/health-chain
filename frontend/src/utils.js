import { ethers } from "ethers"
import ManagementJSON from './contracts/Management.json'
import MedicalHistoryJSON from './contracts/MedicalHistory.json'
import { Web3Storage } from 'web3.storage'
import token_api from "./.secret.json"

const getWeb3 = async () => {
    if (window.ethereum) {
        return new Promise(async (resolve, reject) => {
            try {
                const provider = new ethers.providers.Web3Provider(window.ethereum)
                await provider.send("eth_requestAccounts", [])
                const signer = await provider.getSigner()
                resolve({ provider, signer })
            } catch (error) {
                reject(error)
            }
        })
    } else {
        alert("Install Metamask!")
    }
}

const getManagementContract = (signer = undefined) => {
    if (window.ethereum) {
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const managementAddress = ManagementJSON.address
        const managementABI = ManagementJSON.abi
        let managementContract
        if (signer) {
            managementContract = new ethers.Contract(managementAddress, managementABI, signer)
        } else {
            managementContract = new ethers.Contract(managementAddress, managementABI, provider)
        }

        return managementContract

    } else {
        return undefined
    }
}

const getMedicalHistoryContract = (historyAddress, signer = undefined) => {
    if (window.ethereum) {
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const medicalHistoryABI = MedicalHistoryJSON.abi
        let generatorContract
        if (signer) {
            generatorContract = new ethers.Contract(historyAddress, medicalHistoryABI, signer)
        } else {
            generatorContract = new ethers.Contract(historyAddress, medicalHistoryABI, provider)
        }
        return generatorContract
    } else {
        return undefined
    }
}

const uploadToIPFS = async (file) => {
    const storageClient = new Web3Storage({ token: token_api.REACT_APP_WEB3_STORAGE_API_TOKEN })
    const CID = await storageClient.put([file])

    return CID
}

function toHexString(byteArray) {
    return Array.from(byteArray, function (byte) {
        return ('0' + (byte & 0xFF).toString(16)).slice(-2);
    }).join('')
}

export { getWeb3, getManagementContract, getMedicalHistoryContract, uploadToIPFS, toHexString }