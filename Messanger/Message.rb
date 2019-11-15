
require "./Comment.rb"

class Message



  def initialize(params)
    @params = params
    return unless valid?
    conn = PG.connect( dbname: 'remir', :user => 'remir' )
    conn.exec("INSERT INTO messages(text) VALUES('#{@params[:text]}');")
  end

  def valid?
    @params[:text] != ""
  end

  def self.all
    conn = PG.connect( dbname: 'remir', :user => 'remir')
    conn.exec("SELECT * FROM messages;").to_a
  end

  def self.delete(id)
    conn = PG.connect( dbname: 'remir', :user => 'remir' )
    conn.exec("DELETE FROM messages WHERE id = '#{id}';")
    conn.exec("DELETE FROM comments WHERE message_id  = '#{id}';")
  end

end