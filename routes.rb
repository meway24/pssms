# encoding: utf-8

get "/" do
	erb :index
end

=begin
	主功能模块管理
=end

################## 基础信息模块 ##################
post "/:type/save" do
	logger_user(request.path,params.inspect)
	Log.debug "#{params.inspect}"

	content_type 'applicaton/json',:charset=>'utf-8'
	if eval(params[:type]).save_or_update(params["data"],session[:login_id])
		{message: "保存成功",error_type: "0"}.to_json
	else
		{message: "内部数据错误，请联系管理员",error_type: "-1"}.to_json
	end
end

post "/:type/delete" do
	logger_user(request.path,params.inspect)
	Log.debug "#{params.inspect}"

	content_type 'text/plain',:charset=>'utf-8'
	"删除失败" if !(eval(params[:type]).find(params["id"]).destroy.nil?)
end

post "/:type/:fields" do
	logger_user(request.path,params.inspect)
	Log.debug "#{params.inspect}"
	
	content_type 'applicaton/json'
	total = session[:total] || eval(params["type"]).count
	queryHash = {} 			#查询参数
	add_fields = {}			#额外添加的field
	add_fields = str_to_hash(params["fields"]) unless params["fields"]=="nil" 
	queryHash = {params["queryType"]=>params["queryWord"]} if !params["queryType"].nil? and params["queryWord"]!=""
	Log.debug "#{params[:type]} #{params[:page]} #{params["rows"]} #{queryHash} #{add_fields}"
	return_hash={:total=>total,:rows=>
		eval(params[:type]).easyui_rows(params["page"],params["rows"],queryHash,add_fields)}
	return_hash.to_json
end

=begin
	公共信息模块
=end
######## 获取下拉列表框########
post "/get/:type/:fields/:query/:count" do 
	content_type 'applicaton/json',:charset=>'utf-8'
	fields = "id,name"		#需要查询出来的字段 不需要查询时用nil
	fields = params[:fields] unless params[:fields]=="nil"
	queryHash = {} 			#查询参数 eg：“name=jiyaping” 不需要查询时用nil
	queryHash = str_to_hash(params["query"]) unless params["query"]=="nil"
	count = 10
	count = params[:count] unless params[:count]=="nil" #返回记录数量 nil代表默认是10
	Log.debug "#{fields} #{queryHash} #{count}"
	hash = eval(params[:type]).easyui_special_rows(fields,queryHash,count)
	Log.debug "#{hash}"
	hash.to_json
end

########登录／退出########
get "/login" do 
	erb :login,:layout=>false
end

post "/login" do
	login_id = params["login_id"]
	password = params["password"]

	privilege = User.auth?(login_id,password)

	if(privilege)
		session[:login_id] = login_id
		session[:privilege] = privilege
		redirect "/"
	else
		@error_message = "帐号密码错误";
		redirect to("/login")
	end
end

get "/logout" do
	logger_user(request.path,params.inspect)

	session[:login_id] = nil
	session[:privilege] = nil
	redirect to("/login")
end


=begin
	before / after 公共处理
=end

#before
before do
	content_type :html, 'charset' => 'utf-8' 
	redirect to("/login") if session[:login_id]==nil && request.path!="/login"
end
