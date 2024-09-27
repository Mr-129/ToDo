
// 入力値の検証関数
const isValid = (input) => {
    //入力値空でないか
    //入力文字数10文字制限
    return input !== "" && input.length <= 10;
    }


const app = () => {
    //フォームから値を取得
    let eName =document.querySelector("#name").value;
    //console.log(eName);

    // 入力値の検証
    if (isValid(eName)) {
        console.log("true");
    }
    else{
        console.log("false");
        alert("Invalid input!");
        return;//入力値falseの場合は関数終了

        }
        
    //オブジェクトに格納
    let formData ={
        userName: eName
    };

    //json形式に変換
    let json =JSON.stringify(formData);

    console.log(json);

    // POSTリクエストでサーバーに送信 http://localhost:3000/input
    fetch('http://localhost:3000/input', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: json
    })
    .then(response => response.text())
    .then(data => {
        console.log(data);
        alert(data); // 必要に応じてアラートで表示も可能
    })
    .catch(error => console.error('Error:', error));

}

const app2 = () =>{

    //データ出力予定先を取得
    let eOutput = document.getElementById('container');
    

    //データの取得
    fetch('http://localhost:3000/output',{
        method: 'GET',
    })
    .then(response => response.json())// JSONデータをJavaScriptのオブジェクトに変換
    .then(data => {
        for(let i=0; i<data.length;i++){
            
            eOutput.innerHTML += `<p>${data[i].id}</p>`;
            eOutput.innerHTML +=`<p>${data[i].name}</p>`;
            
            //console.log(data[i].id);
            //console.log(data[i].name);
        }
    })
        .catch(error => { 
        console.error('Error:',error);
    });
}

//入力のボタンがクリックされたとき
let inputBtn =document.querySelector("#inputBtn");
inputBtn.addEventListener("click",app);

let outputBtn =document.querySelector("#outputBtn");
outputBtn.addEventListener("click",app2);


