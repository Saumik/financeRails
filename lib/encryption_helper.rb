module EncryptionHelper
  MY_SALT = 'abcdefghjklm'

  def aes(method,key,t)
    aes = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    aes.send(method).key = Digest::SHA256.digest(key)
    result = aes.update(t)
    result << aes.final
    result
  end

  def encrypt(key, text)
    aes(:encrypt, key, text)
  end

  def decrypt(key, text)
    aes(:decrypt, key, text)
  end
end