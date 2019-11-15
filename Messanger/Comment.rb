require "./Message.rb"

class Comment

  def initialize(params)
    @params = params
    return unless valid?
    rs = conn.exec("SELECT (id) FROM messages WHERE id = #{@params[:message_id]};")
    if rs.ntuples != 0 then
    conn.exec("INSERT INTO comments (text,message_id) VALUES('#{params[:text]}',#{params[:message_id]})")  
  end
  end

  def valid?
    @params[:text] != ""
    @params[:message_id] != ""   
  end


  def self.all
    conn = PG.connect( dbname: 'remir', :user => 'remir' )
    conn.exec("SELECT * FROM comments;").to_a
  end

  def self.delete(id)
    conn = PG.connect( dbname: 'remir', :user => 'remir' )
    conn.exec("DELETE FROM comments WHERE id = '#{id}';")
  end


  def conn
    @conn ||= PG.connect( dbname: 'remir', :user => 'remir' )
  end


end