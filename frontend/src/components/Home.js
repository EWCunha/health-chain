import React from 'react'

const Home = () => {
    return (
        <div>
          <div className='max-w-[800px] mt-[-96px] w-full h-screen mx-auto text-center flex flex-col justify-center'>
            <p className='text-[#282c34] font-bold p-2'>
                SAÚDE ON-CHAIN
            </p>
            <h1 className='md:text-7xl sm:text-6xl text-4xl font-bold md:py-6'>
                Health Chain
            </h1>
            <div className='flex justify-center items-center'>
              <p className='md:text-5xl sm:text-4xl text-xl font-bold py-4'>
                Sistema de recompensa de fornecimento de dados de saúde.
              </p>
            </div>
              <p className='md:text-2xl text-xl font-bold text-gray-500'>
                Forneça dados e seja recompensado em BNB ou BUSD.
              </p>
          </div>
        </div>
      );
}

export default Home