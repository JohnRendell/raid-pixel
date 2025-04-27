async function createAccount(){
    var username = document.getElementById("username_input");
    var password = document.getElementById("password_input");
    var confirm_password = document.getElementById("confirm_pass_input");

    if(!username.value || !password.value || !confirm_password.value){
        alert("All fields must be inputted.")
    }
    else if(username.value.length <= 4){
        alert("Username character length must above 4")
    }
    else if(password.value.length <= 4){
        alert("Password character length must above 4")
    }
    else if(password.value != confirm_password.value){
        alert("Password and confirm password not match.")
    }
    else{
        try{
            const createAcc = await fetch("/accountRoute/createAccount", {
                method: "POST",
                headers: {
                    "Accept": "application/json",
                    "Content-Type": "application/json"
                },
                body: JSON.stringify({ username: username.value, password: password.value })
            });

            const createAcc_data = await createAcc.json();

            if(createAcc_data.status == "Success"){
                alert("Account Created")
            }
            else{
                alert(createAcc_data.status)
            }
        }
        catch(err){
            console.log(err);
        }
    }
}