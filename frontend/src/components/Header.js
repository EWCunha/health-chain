import React from 'react'
import { Link } from 'react-router-dom'
import { AppBar, Toolbar, CssBaseline, Typography, IconButton, Box, Button } from '@mui/material'
import { logo } from "../assets";

const Header = () => {

  return (
    <>
      <AppBar position="static" sx={{ marginBottom: 2, }}>
        <CssBaseline />
        <Toolbar>
          <IconButton component={Link}
            to="/"
          >
            <img src={logo} alt="healtchain" className="logo" />
          </IconButton>

          <Box
            sx={{
              width: "50%",
              mx: "auto",
              bgcolor: "none",
              display: "flex",
              justifyContent: "space-around",
              alignItems: "center"
            }}>
            <Button component={Link}
              to="/"
            >
              <Typography sx={{ color: "white" }}>
                Home
              </Typography>
            </Button>
            <Button component={Link}
              to="/hospital"
            >
              <Typography sx={{ color: "white" }}>
                Hospital
              </Typography>
            </Button>
            <Button component={Link}
              to="/patient"
            >
              <Typography sx={{ color: "white" }}>
                Patient
              </Typography>
            </Button>
          </Box>
        </Toolbar>
      </AppBar>
    </>
  )
}

export default Header