//
//  ContentView.swift
//  CodingClub
//
//  Created by Aang Muammar Zein on 11/07/23.
//

import SwiftUI

struct ContentView: View {
    
    @State var items:[DataModel] = []
    @State var dataDetail:DataModel = DataModel(id: "", translate_en: "", translate_id: "", created_at: "")
    @State var page:Int = 1
    @State var msg:String = ""
    @State var words:String = ""
    @State var isDone:Bool = false
    @State var isLoading:Bool = false
    @State var isCreate:Bool = false
    @State var isUpdate:Bool = false
    @State var isDelete:Bool = false
    @State var isAlert:Bool = false
    
    
    func getData(){
        print("Page : "+String(page))
        isLoading = true
        let url = URL(string: "https://dev.nikahnesia.com/api/codingclub/v1/list-data?page="+String(page))!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            let decoder = JSONDecoder()
            if let data = data{
                //                print(String(data: data, encoding: .utf8)!)
                do {
                    let data = try decoder.decode(ResponseModel.self, from: data)
                    
                    if(data.data.count == 0){
                        isDone = true
                    }
                    
                    if(page == 1){
                        items.removeAll()
                    }
                    
                    for i in 0..<data.data.count {
                        items.append(data.data[i])
                    }
                    isLoading = false
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    func deleteData(){
        isLoading = true
        
        let parameters = [
        ] as [[String: Any]]
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        var _: Error? = nil
        for param in parameters {
            if param["disabled"] != nil { continue }
            let paramName = param["key"]!
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            if param["contentType"] != nil {
                body += "\r\nContent-Type: \(param["contentType"] as! String)"
            }
            let paramType = param["type"] as! String
            if paramType == "text" {
                let paramValue = param["value"] as! String
                body += "\r\n\r\n\(paramValue)\r\n"
            } else {
            }
        }
        body += "--\(boundary)--\r\n";
        let postData = body.data(using: .utf8)
        
        var request = URLRequest(url: URL(string: "https://dev.nikahnesia.com/api/codingclub/v1/delete-data?id="+dataDetail.id)!,timeoutInterval: Double.infinity)
        request.addValue("ci_session=1cec0a9612e787a43a48f30955c5704b22038359", forHTTPHeaderField: "Cookie")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "DELETE"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let decoder = JSONDecoder()
            if let data = data{
//                print(String(data: data, encoding: .utf8)!)
                do {
                    let data = try decoder.decode(ResponseModelWithoutData.self, from: data)
                    msg = data.message
                    isAlert = true
                    isLoading = false
                } catch {
                    print(error)
                }
                page = 1
                isDone = false
                getData()
            }
        }
        
        task.resume()
        
    }
    
    func updateData(){
        isLoading = true
        if(dataDetail.translate_en==""){
            msg = "English words cannot be empty!"
            isAlert = true
            isLoading = false
        }else if(dataDetail.translate_id==""){
            msg = "Indonesia words cannot be empty!"
            isAlert = true
            isLoading = false
        }else{
            let parameters = "{\n   \"translate_en\":\""+dataDetail.translate_en+"\",\n   \"translate_id\":\""+dataDetail.translate_id+"\"\n}"
            
            
            let postData = parameters.data(using: .utf8)
            
            var request = URLRequest(url: URL(string: "https://dev.nikahnesia.com/api/codingclub/v1/update-data?id="+dataDetail.id)!,timeoutInterval: Double.infinity)
            request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
            request.addValue("ci_session=1cec0a9612e787a43a48f30955c5704b22038359", forHTTPHeaderField: "Cookie")
            
            request.httpMethod = "PUT"
            request.httpBody = postData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                let decoder = JSONDecoder()
                if let data = data{
                    //                       print(String(data: data, encoding: .utf8)!)
                    do {
                        let data = try decoder.decode(ResponseModelWithoutData.self, from: data)
                        msg = data.message
                        isAlert = true
                        isLoading = false
                    } catch {
                        print(error)
                    }
                    isDone = false
                    page = 1
                    getData()
                }
            }
            
            task.resume()
            
            
        }
    }
    
    func createData(){
        isLoading = true
        if(words==""){
            msg = "Words cannot be empty!"
            isAlert = true
            isLoading = false
        }else{
            
            let currentDate = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateFormatter.string(from: currentDate)
            
            let parameters = [
                [
                    "key": "word",
                    "value": String(words),
                    "type": "text"
                ],
                [
                    "key": "created_at",
                    "value": String(date),
                    "type": "text"
                ]] as [[String: Any]]
            
            let boundary = "Boundary-\(UUID().uuidString)"
            var body = ""
            var _: Error? = nil
            for param in parameters {
                if param["disabled"] != nil { continue }
                let paramName = param["key"]!
                body += "--\(boundary)\r\n"
                body += "Content-Disposition:form-data; name=\"\(paramName)\""
                if param["contentType"] != nil {
                    body += "\r\nContent-Type: \(param["contentType"] as! String)"
                }
                let paramType = param["type"] as! String
                if paramType == "text" {
                    let paramValue = param["value"] as! String
                    body += "\r\n\r\n\(paramValue)\r\n"
                } else {
                    //                let paramSrc = param["src"] as! String
                    //                let fileData = try NSData(contentsOfFile: paramSrc, options: []) as Data
                    //                let fileContent = String(data: fileData, encoding: .utf8)!
                    //                body += "; filename=\"\(paramSrc)\"\r\n"
                    //                  + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
                }
            }
            body += "--\(boundary)--\r\n";
            let postData = body.data(using: .utf8)
            
            var request = URLRequest(url: URL(string: "https://dev.nikahnesia.com/api/codingclub/v1/push-data")!,timeoutInterval: Double.infinity)
            request.addValue("ci_session=82ae4e88b6f92dc21e5254af2c6bc811a9b58370", forHTTPHeaderField: "Cookie")
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            request.httpMethod = "POST"
            request.httpBody = postData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                let decoder = JSONDecoder()
                if let data = data{
                    //                        print(String(data: data, encoding: .utf8)!)
                    do {
                        let data = try decoder.decode(ResponseModelWithoutData.self, from: data)
                        if(data.status==true){
                            words = ""
                        }
                        msg = data.message
                        isAlert = true
                        isLoading = false
                    } catch {
                        print(error)
                    }
                    page = 1
                    isDone = false
                    getData()
                }
                
            }
            task.resume()
        }
    }
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false){
                ForEach(items, id: \.self) { item in
                    VStack(){
                        VStack(spacing:10){
                            HStack(){
                                Text(item.translate_en)
                                Spacer()
                                Text(item.translate_id)
                            }
                            HStack(){
                                Text(item.created_at)
                                Spacer()
                                HStack(spacing:2){
                                    Button(
                                        action:{
                                            isUpdate = true
                                            dataDetail = item
                                        }
                                    ){
                                        Image(systemName: "square.and.pencil.circle").foregroundColor(.blue)
                                    } .sheet(isPresented: $isUpdate) {
                                        VStack(alignment:.leading, spacing:20){
                                            Text("Form Update Data").foregroundColor(Color.white).font(.title)
                                            Text("English Language").foregroundColor(Color.white).font(.body)
                                            TextField("", text: $dataDetail.translate_en).font(.body).padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(.white, lineWidth: 1.5)
                                                ).foregroundColor(.white).accentColor(.white)
                                            Text("Indonesia Language").foregroundColor(Color.white).font(.body)
                                            TextField("", text: $dataDetail.translate_id).font(.body).padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(.white, lineWidth: 1.5)
                                                ).foregroundColor(.white).accentColor(.white).padding(.bottom,10)
                                            if(isLoading){
                                                LoadingView()
                                            }else{
                                                Button(action: {
                                                    updateData()
                                                }) {
                                                    Text("Update Data").font(.body).fontWeight(.none).foregroundColor(Color.black).padding(15).frame(maxWidth:.infinity).background(Color.white).cornerRadius(10)
                                                    
                                                    
                                                }.alert(isPresented: $isAlert) {
                                                    Alert(
                                                        title: Text("Notification"),
                                                        message: Text(msg),
                                                        dismissButton: .default(Text("OK"))
                                                    )
                                                }
                                            }
                                            
                                            
                                        }.padding(20).frame(maxHeight:.infinity).background(.blue.opacity(0.8)).presentationDetents(
                                            [.medium, .medium]
                                        ).cornerRadius(10)
                                    }
                                    Button(
                                        action:{
                                            isDelete = true
                                            dataDetail = item
                                        }
                                    ){
                                        Image(systemName: "trash.circle").foregroundColor(.red)
                                    }.sheet(isPresented: $isDelete) {
                                        VStack(alignment:.leading, spacing:20){
                                            Text("Delete Data Confirmation").foregroundColor(Color.white).font(.title)
                                            Text("Are your sure want to delete this data? ").foregroundColor(Color.white).font(.body)
                                            Text("English Language").foregroundColor(Color.white).font(.body)
                                            TextField("", text: $dataDetail.translate_en).font(.body).padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(.white, lineWidth: 1.5)
                                                ).foregroundColor(.white).accentColor(.white).disabled(true)
                                            Text("Indonesia Language").foregroundColor(Color.white).font(.body)
                                            TextField("", text: $dataDetail.translate_id).font(.body).padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(.white, lineWidth: 1.5)
                                                ).foregroundColor(.white).accentColor(.white).padding(.bottom,10).disabled(true)
                                            if(isLoading){
                                                LoadingView()
                                            }else{
                                                Button(action: {
                                                    deleteData()
                                                }) {
                                                    Text("Delete Data").font(.body).fontWeight(.none).foregroundColor(Color.black).padding(15).frame(maxWidth:.infinity).background(Color.white).cornerRadius(10)
                                                    
                                                    
                                                }.alert(isPresented: $isAlert) {
                                                    Alert(
                                                        title: Text("Notification"),
                                                        message: Text(msg),
                                                        dismissButton: .default(Text("OK"))
                                                    )
                                                }
                                                
                                            }
                                            
                                            
                                        }.padding(20).frame(maxHeight:.infinity).background(.red.opacity(0.8)).presentationDetents(
                                            [.medium, .medium]
                                        ).cornerRadius(10)
                                    }
                                }
                            }
                        }.padding(20)
                    }
                    .background(.white)
                    .cornerRadius(10)
                }
                if(isLoading){
                    HStack(spacing:5){
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            .font(.body)
                        Text("Loading...")
                    }.padding(.top,20)
                }
            }.refreshable {
                isDone = false
                page = 1
                if(!isDone){
                    getData()
                }
            }.simultaneousGesture(DragGesture().onChanged({ _ in
                page += 1
                if(!isDone){
                    getData()
                }
            }
                                                         )
            )
            Button(
                action:{
                    isCreate = true
                }
            ){
                Text("Create Data").foregroundColor(.white)
            }
            .padding(20)
            .frame(maxWidth:.infinity)
            .background(.blue.opacity(1))
            .cornerRadius(10).padding(.top,20).sheet(isPresented: $isCreate) {
                VStack(alignment:.leading, spacing:20){
                    Text("Form Create Data").foregroundColor(Color.white).font(.title)
                    Text("English Language").foregroundColor(Color.white).font(.body)
                    TextField("", text: $words).font(.body).padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white, lineWidth: 1.5)
                        ).foregroundColor(.white).accentColor(.white).padding(.bottom,10)
                    if(isLoading){
                        LoadingView()
                    }else{
                        Button(action: {
                            createData()
                        }) {
                            Text("Create Data").font(.body).fontWeight(.none).foregroundColor(Color.black).padding(15).frame(maxWidth:.infinity).background(Color.white).cornerRadius(10)
                            
                            
                        }.alert(isPresented: $isAlert) {
                            Alert(
                                title: Text("Notification"),
                                message: Text(msg),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                    
                }.padding(20).frame(maxHeight:.infinity).background(.blue).presentationDetents(
                    [.height(300), .medium]
                )
            }
            
        }
        .padding(20)
        .frame(maxWidth:.infinity,maxHeight:.infinity)
        .background(.blue.opacity(0.4)).onAppear{
            getData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct LoadingView: View {
    var body: some View {
        Button(action: {
            
        }) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                .scaleEffect(1.5).font(.body).fontWeight(.none).foregroundColor(Color.black).padding(15).frame(maxWidth:.infinity).background(Color.white).cornerRadius(10)
        }.disabled(true)
        
    }
}
