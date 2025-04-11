  class FoodData {
    static List<Map<String, String>> getFoodItems(String category) {
      final List<Map<String, String>> allItems = [];

      if (category == 'All' || category == 'Food') {
        allItems.addAll([
          {
            "title": "Soto Ayam",
            "subtitle": "Masakan Minang",
            "time": "8 mins",
            "imgUrl": "assets/food/soto_ayam.jpg",
            "price": "20.000",
            "sellerEmail": "456@seller.umn.ac.id",
          },
          {
            "title": "Nasi Pecel",
            "subtitle": "Masakan Minang",
            "time": "5 mins",
            "imgUrl": "assets/food/nasi_pecel.jpg",
            "price": "15.000",
            "sellerEmail": "456@seller.umn.ac.id",
          },
          {
            "title": "Bakso",
            "subtitle": "Bakso 88",
            "time": "15 mins",
            "imgUrl": "assets/food/bakso.jpg",
            "price": "20.000",
          },
          {
            "title": "Mie Ayam",
            "subtitle": "Mie Ayam Enak",
            "time": "3 mins",
            "imgUrl": "assets/food/mie_ayam.jpg",
            "price": "20.000",
          },
        ]);
      }

      if (category == 'All' || category == 'Drinks') {
        allItems.addAll([
          {
            "title": "Matcha Latte",
            "subtitle": "KopiKu",
            "time": "10 mins",
            "imgUrl": "assets/drink/matcha_latte.jpg",
            "price": "25.000",
          },
          {
            "title": "Cappucino",
            "subtitle": "KopiKu",
            "time": "6 mins",
            "imgUrl": "assets/drink/cappucino.jpg",
            "price": "8.000",
          },
        ]);
      }

      if (category == 'All' || category == 'Snack') {
        allItems.addAll([
          {
            "title": "Burger",
            "subtitle": "Aneka Makanan",
            "time": "10 mins",
            "imgUrl": "assets/snack/burger.jpg",
            "price": "30.000",
          },
          {
            "title": "Kentang Goreng",
            "subtitle": "Fast Food Restaurant",
            "time": "3 mins",
            "imgUrl": "assets/snack/french_fries.jpg",
            "price": "12.000",
          },
        ]);
      }

      return allItems;
    }
  }
