import firebase_admin
from firebase_admin import credentials, firestore
import os
import base64

# Initialize Firebase
cred = credentials.Certificate('service_account_key.json')
firebase_admin.initialize_app(cred, {
    'storageBucket': 'u-teen-e88b6.appspot.com'
})

db = firestore.client()

# Product data with local image paths
products = [
    {
        'id': 'product1',
        'title': 'Soto Ayam',
        'subtitle': 'Masakan Minang',
        'time': '8 mins',
        'price': '20000',
        'sellerEmail': '456@seller.umn.ac.id',
        'tenantName': 'Masakan Minang',
        'isActive': True,
        'category': 'Food',  # Diperbarui ke kategori yang valid
        'localImagePath': 'images/soto_ayam.jpg'
    },
    {
        'id': 'product2',
        'title': 'Nasi Pecel',
        'subtitle': 'Masakan Minang',
        'time': '5 mins',
        'price': '15000',
        'sellerEmail': '456@seller.umn.ac.id',
        'tenantName': 'Masakan Minang',
        'isActive': True,
        'category': 'Food',  # Diperbarui ke kategori yang valid
        'localImagePath': 'images/nasi_pecel.jpg'
    },
    {
        'id': 'product3',
        'title': 'Bakso',
        'subtitle': 'Bakso 88',
        'time': '15 mins',
        'price': '20000',
        'sellerEmail': '456@seller.umn.ac.id',
        'tenantName': 'Bakso 88',
        'isActive': True,
        'category': 'Food',  # Diperbarui ke kategori yang valid
        'localImagePath': 'images/bakso.jpg'
    },
    {
        'id': 'product4',
        'title': 'Mie Ayam',
        'subtitle': 'Mie Ayam Enak',
        'time': '3 mins',
        'price': '20000',
        'sellerEmail': '456@seller.umn.ac.id',
        'tenantName': 'Mie Ayam Enak',
        'isActive': True,
        'category': 'Food',  # Diperbarui ke kategori yang valid
        'localImagePath': 'images/mie_ayam.jpg'
    },
    {
        'id': 'product5',
        'title': 'Matcha Latte',
        'subtitle': 'KopiKu',
        'time': '10 mins',
        'price': '25000',
        'sellerEmail': '456@seller.umn.ac.id',
        'tenantName': 'KopiKu',
        'isActive': True,
        'category': 'Drink',  # Diperbarui ke kategori yang valid
        'localImagePath': 'images/matcha_latte.jpg'
    },
    {
        'id': 'product6',
        'title': 'Cappucino',
        'subtitle': 'KopiKu',
        'time': '6 mins',
        'price': '8000',
        'sellerEmail': '456@seller.umn.ac.id',
        'tenantName': 'KopiKu',
        'isActive': True,
        'category': 'Drink',  # Diperbarui ke kategori yang valid
        'localImagePath': 'images/cappucino.jpg'
    },
    {
        'id': 'product7',
        'title': 'Burger',
        'subtitle': 'Aneka Makanan',
        'time': '10 mins',
        'price': '30000',
        'sellerEmail': '456@seller.umn.ac.id',
        'tenantName': 'Aneka Makanan',
        'isActive': True,
        'category': 'Snack',  # Diperbarui ke kategori yang valid
        'localImagePath': 'images/burger.jpg'
    },
    {
        'id': 'product8',
        'title': 'Kentang Goreng',
        'subtitle': 'Fast Food Restaurant',
        'time': '3 mins',
        'price': '12000',
        'sellerEmail': '456@seller.umn.ac.id',
        'tenantName': 'Fast Food Restaurant',
        'isActive': True,
        'category': 'Snack',  # Diperbarui ke kategori yang valid
        'localImagePath': 'images/french_fries.jpg'
    },
]

def image_to_base64(local_path):
    """Convert image to Base64 string with size validation."""
    if not os.path.exists(local_path):
        print(f"Image not found: {local_path}")
        return ''
    try:
        with open(local_path, "rb") as image_file:
            base64_data = base64.b64encode(image_file.read()).decode('utf-8')
            # Periksa ukuran Base64 (1 MB batas Firestore)
            if len(base64_data) > 1000000:  # Kurang dari 1 MB
                print(f"Image {local_path} too large for Base64 (exceeds 1 MB)")
                return ''
            return base64_data
    except Exception as e:
        print(f"Error encoding image: {e}")
        return ''

def initialize_products(use_base64=False):
    """Initialize products in Firestore with images from Base64."""
    products_collection = db.collection('products')
    if products_collection.limit(1).get():
        print('Products already exist, merging new data.')
        # Gunakan merge=True untuk menambahkan field yang hilang
        for product in products:
            product_id = product['id']
            local_image_path = product.pop('localImagePath')
            if use_base64:
                product['imgBase64'] = image_to_base64(local_image_path)
                if not product['imgBase64']:
                    print(f'Skipped product {product_id} due to Base64 encoding failure')
                    continue
            products_collection.document(product_id).set(product, merge=True)  # Tambahkan merge=True
            print(f'Merged/Initialized product: {product_id}')
    else:
        print('No products exist, initializing new data.')
        for product in products:
            product_id = product['id']
            local_image_path = product.pop('localImagePath')
            if use_base64:
                product['imgBase64'] = image_to_base64(local_image_path)
                if not product['imgBase64']:
                    print(f'Skipped product {product_id} due to Base64 encoding failure')
                    continue
            products_collection.document(product_id).set(product)
            print(f'Initialized product: {product_id}')

def initialize_popular_cuisines():
    """Initialize popular_cuisines collection."""
    doc_ref = db.collection('popular_cuisines').document('cuisines')
    if not doc_ref.get().exists:
        doc_ref.set({
            'items': ['Soto', 'Nasi Pecel', 'Bakso', 'Rice', 'Bakso & Soto', 'Coffee']
        })
        print('Popular cuisines initialized.')
    else:
        print('Popular cuisines already initialized.')

def main(use_base64=False):
    """Main function to initialize Firestore."""
    metadata_ref = db.collection('metadata').document('initialized')
    if metadata_ref.get().exists and metadata_ref.get().to_dict().get('status'):
        print('Database already initialized.')
        return

    initialize_products(use_base64)
    initialize_popular_cuisines()
    metadata_ref.set({'status': True})
    print('Database initialization completed.')

if __name__ == '__main__':
    main(use_base64=True)