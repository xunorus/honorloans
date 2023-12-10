

function askToPayForGas(){


  Swal.fire({
    title: "User is asking you to pay for the gas!",
    position: "center-start",
    icon: "question",
    showConfirmButton: true,
    confirmButtonText: 'Accept',
    showCancelButton: true,
    cancelButtonText: 'Decline',
    backdrop: true,
    preConfirm: (login) => { },
    allowOutsideClick: () => {
      const popup = Swal.getPopup()
      popup.classList.remove('swal2-show')
      setTimeout(() => { popup.classList.add('animate__animated', 'animate__headShake') })
      setTimeout(() => { popup.classList.remove('animate__animated', 'animate__headShake') }, 500)
      return false
    }
  })
  
      .then((result) => {
      if (result.isConfirmed) { 
        console.log('CONFIRMED!') 
        accept()
        
      }
      else if (result.isDismissed ) { 
        console.log('DISMISSED'); 
        decline();
        }
      }
      )
  
      function accept (){
        console.log('accept ...')
      }
  
  
      function decline (){
        console.log('decline ...')
      }
}

askToPayForGas()





