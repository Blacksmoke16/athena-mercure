module TokenFactoryInterface
  abstract def create(
    subscribe : Array(String)? = [] of String,
    publish : Array(String)? = [] of String,
    additional_claims : Hash(String, String | Array(String)) = {} of String => String | Array(String)
  ) : String
end

@[ADI::Register(_jwt_secret: ENV["MERCURE_JWT_SECRET"])]
struct CrystalCommunityJWTFactory
  include TokenFactoryInterface

  def initialize(@jwt_secret : String); end

  def create(
    subscribe : Array(String)? = [] of String,
    publish : Array(String)? = [] of String,
    additional_claims : Hash(String, String | Array(String)) = {} of String => String | Array(String)
  ) : String
    tokens = {} of String => String | Array(String)
    unless subscribe.empty?
      tokens["subscribe"] = subscribe
    end

    unless publish.empty?
      tokens["publish"] = publish
    end

    payload = {"mercure" => tokens}

    # TODO: Merge in additional claims

    JWT.encode payload, @jwt_secret, JWT::Algorithm::HS256
  end
end
