# Model to initialize setup process
class Snapshot
  include Mongoid::Document
  
  @@apiserver = "http://#{Setting.first.apiserver}:#{Setting.first.apiport}"

  def self.discover(identifier)
    request = Http.get("#{@@apiserver}/machine/#{identifier}/snapshots", {})
    unprocessed_json = JSON.parse(request.body)

    begin
      if unprocessed_json.key? 'error'
        return []
      else
        data = JSON.parse(request.body, object_class: OpenStruct)
        return data
      end
    rescue NoMethodError
      data = JSON.parse(request.body, object_class: OpenStruct)
      return data
    end

  end

  def self.make(identifier, snapname)
    puts "#{identifier}: creating snapshot #{snapname}"
  	request = Http.post("#{@@apiserver}/machine/#{identifier}/snapshot/#{snapname}", {})

    json = JSON.parse(request.body)

    if json.any?
      if json.key? "uuid"
        @uuid = json["uuid"]
        return @uuid
      else
        return false
      end
    else
      return false
    end

    return false

  end

  def self.destroy(identifier, uuid)
    puts "#{identifier}: deleting snapshot with UUID #{uuid}"
  	request = Http.delete("#{@@apiserver}/machine/#{identifier}/snapshot/#{uuid}", {})
    json = JSON.parse(request.body)

    if json.any?
      status = json['status']
      if status == "ok"
        return true
      else
        return false
      end

    else
      return false
    end
    return false
  end

end