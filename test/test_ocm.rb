gem 'test-unit'
require 'test/unit'
require 'yaml'
require_relative 'test_base'
require_relative 'contact'

class TestOcm < TestBase
  def setup
    super


  end

  def test_basics
    orm = Ocm::Orm.new

    contact = Contact.new(:name=>"t2")
    puts contact.name
    contact.name = "travis"
    puts contact.name
    orm.save(contact)
    p contact
    id = contact.id
    contact2 = orm.find(Contact, id)
    p contact2
    assert_equal id, contact2.id
    assert_equal contact.name, contact2.name

    list_name = "my_list"
    list = []
    10.times do |i|
      c = Contact.new
      c.name = "name #{i}"
      orm.save(c)
      list << c
    end
    orm.save_list(list_name, list)

    list2 = orm.get_list(list_name)
    list2.each_with_index do |c,i|
      assert_equal list[i].id, c.id
      assert_equal list[i].name, c.name
    end

    c10 = Contact.new(name: "name 10")
    orm.append_to_list(list_name, c10)
    list3 = orm.get_list(list_name)
    p list3
    assert_equal c10.name, list3[10].name


  end

end

