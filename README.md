# Bankin'

Ruby client for the [Bankin' API](https://docs.bridgeapi.io/docs).

## Register

First you need to create your own client application on
[bridgeapi.io/dashboard/apps](https://bridgeapi.io/dashboard/apps).

You'll get your credentials, needed for every API request.

## Configure

```rb
Bankin.configure do |c|
  c.client_id = 'YOUR_CLIENT_ID'
  c.client_secret = 'YOUR_CLIENT_SECRET'
end
```

## Users

### Create

Create users registered to your client app.

```rb
Bankin::User.create('EMAIL', 'PASSWORD')
```

### Authenticate

Once you registered a user to your cient app, your can authenticate and get your
user token for some authenticated requests.

```rb
token = Bankin::User.authenticate('EMAIL', 'PASSWORD').token
```

## Resources

### Banks

```rb
Bankin::Bank.list    # List of 50 last supported banks
Bankin::Bank.get(1)  # Retrieve the details of a supported bank
```

### Transactions

```rb
Bankin::Transaction.list(token)    # List of 50 last transactions
Bankin::Transaction.get(token, 1)  # Retrieve the details of a single transaction
```

## Pagnation

All `Collection` resources are paginated.

```rb
banks = Bankin::Bank.list  # List of 50 banks
bans.next_page?            # => true
banks.next_page!           # Loads 50 next banks
banks.load_all!            # Loads all remaining banks
```
