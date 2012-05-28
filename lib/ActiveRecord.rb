# encoding: utf-8

class ActiveRecord::Base
	#获取指定列信息返回
	def self.easyui_special_rows(fields="id,name")
		rows = []
		self.select(fields).each do |obj|
			rows<<obj.attributes
		end

		rows
	end

	#整体属性转化为hash
 	def to_full_hash
 		hash = {}
		instance_variables.each do |var|
			hash[var.to_s.delete! '@']=instance_variable_get var
		end
		hash
 	end

 	#返回指定rows的数组
	def self.easyui_rows(pageNum,pageSize,params={})
		keystr = build_query_str(params)
		keyHash = build_query_hash(params)
		limit = pageSize || 10
		pageNum = pageNum || 1
		offset = (pageNum.to_i-1) * pageSize.to_i
		rows = []
		#puts "#{limit} #{offset} #{keystr} #{keyHash}"
		self.where(keystr,keyHash).limit(limit).offset(offset).each do |obj|
			rows<<obj.attributes
		end

		rows
	end

	#保存还是更新
	def self.save_or_update(params={},login_id='',key="id")
		params["id"] = params["id"] || ""
		if params["id"]!=""
			return find(params["id"].to_s).update_attributes(params.merge!(add_other_info(login_id)))
		else
			Log.debug "#{params.merge!(add_other_info(login_id,"add"))}"
			return create(params.merge!(add_other_info(login_id,"add")))
		end
		false
	end

	private
	#构造条件字符串
	def self.build_query_str(params={})
		result_str = ''
		params.keys.each do |p|
			result_str<<p.to_s<<" =:#{p.to_sym}"
			result_str<<" and " if params.keys.last!=p
		end
		result_str
	end

	#构造值value哈希
	def self.build_query_hash(params={})
		newhash = params.inject({}) { |h,(k,v)| h[k.to_sym] = v; h }
		newhash
	end

	#添加而外信息
	def self.add_other_info(login_id="",add_or_upd="upd")
		info_hash = {}
		if(add_or_upd=="upd")
			info_hash["upd_id"] = login_id
			info_hash["upd_date"] = Time.now.strftime("%F %T")
		else
			info_hash["add_id"] = login_id
			info_hash["add_date"] = Time.now.strftime("%F %T")
		end
		info_hash
	end
end