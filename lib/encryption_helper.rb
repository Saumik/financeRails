module EncryptionHelper
  MY_SALT = 'fda0cb6e5c7507aa1be1717760e04ac0'

  def aes(method,key,iv,text)
    aes = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    aes.send(method)
    aes.key = Digest::SHA256.digest(key)
    if iv.present?
      aes.iv = iv
    else
      iv = aes.random_iv
    end
    result = aes.update(text) + aes.final
    [iv, result]
  end

  def encrypt(key, text)
    aes(:encrypt, key, nil, text)
  end

  def decrypt(key, iv, text)
    aes(:decrypt, key, iv, text)[1]
  end
end