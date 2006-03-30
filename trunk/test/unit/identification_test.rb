require File.dirname(__FILE__) + '/../test_helper'

class IdentificationTest < Test::Unit::TestCase
  fixtures :identifications

  def test_should_create_identification
    assert create_identification.valid?
  end

  def test_should_require_login
    u = create_identification(:login => nil)
    assert u.errors.on(:login)
  end

  def test_should_require_password
    u = create_identification(:password => nil)
    assert u.errors.on(:password)
  end

  def test_should_require_password_confirmation
    u = create_identification(:password_confirmation => nil)
    assert u.errors.on(:password_confirmation)
  end

  def test_should_require_email
    u = create_identification(:email => nil)
    assert u.errors.on(:email)
  end

  def test_should_reset_password
    identifications(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal identifications(:quentin), Identification.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    identifications(:quentin).update_attribute(:login, 'quentin2')
    assert_equal identifications(:quentin), Identification.authenticate('quentin2', 'quentin')
  end

  def test_should_authenticate_identification
    assert_equal identifications(:quentin), Identification.authenticate('quentin', 'quentin')
  end

  protected
  def create_identification(options = {})
    Identification.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
  end
end
