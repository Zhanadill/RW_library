/// These materials have been reviewed and are updated as of September, 2020
///
/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
///


import UIKit

final class LibraryController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  //Here we specified TutorialCollection as Section Type and Tutorial as Item Type
  var dataSource : UICollectionViewDiffableDataSource<TutorialCollection, Tutorial>!
  //Для того чтобы извлекать данные из файла DataSource
  private let tutorialCollections = DataSource.shared.tutorials
    
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  private func setupView() {
    self.title = "Library"
    
    //связали с TitleSupplementaryView для настройки header-a
    collectionView.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
    
    
    collectionView.delegate = self
    collectionView.collectionViewLayout = configureCollectionViewLayout()
    configureDataSource()
    configureSnapshot()
  }
}



//MARK: - CollectionView -
extension LibraryController {
    //Указали размеры для itema group и section
    func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) ->
            NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6), heightDimension: .fractionalHeight(0.3))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            
            //указали как будет производиться scrolling можно сделать скроллинг или сделать так чтобы листался
            section.orthogonalScrollingBehavior = .continuous
            //section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            //section.orthogonalScrollingBehavior = .groupPaging
            section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            //указали расстояние между item-ами в группе
            section.interGroupSpacing = 10
            
            
            //указали размеры для header-a
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}



//MARK: - Diffable DataSource -
extension LibraryController {
    //указали section и item
    typealias TutorialDataSource = UICollectionViewDiffableDataSource<TutorialCollection, Tutorial>
    
    
    //Присвоили значения UI-элементам cell-a
    func configureDataSource(){
        dataSource = TutorialDataSource(collectionView: collectionView){
            (collectionView: UICollectionView, indexPath: IndexPath, tutorial: Tutorial) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TutorialCell.reuseIdentifier, for: indexPath) as? TutorialCell else{
                return nil
            }
            
            cell.titleLabel.text = tutorial.title
            cell.thumbnailImageView.image = tutorial.image
            cell.thumbnailImageView.backgroundColor = tutorial.imageBackgroundColor
            
            return cell
        }
        
        
        //нужен для настройки header-a
        dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
          
          if let self = self, let titleSupplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier, for: indexPath) as? TitleSupplementaryView {
            
            let tutorialCollection = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            titleSupplementaryView.textLabel.text = tutorialCollection.title
            
            return titleSupplementaryView
          } else {
            return nil
          }
        }
    }
    
    
    //извлекаем секции и обьекты которые относятся к определенным секциям
    func configureSnapshot() {
        var currentSnapshot = NSDiffableDataSourceSnapshot<TutorialCollection, Tutorial>()
        
        tutorialCollections.forEach{ collection in
            currentSnapshot.appendSections([collection])
            currentSnapshot.appendItems(collection.tutorials)
        }
        
        dataSource.apply(currentSnapshot, animatingDifferences: false)
    }
}




// MARK: - UICollectionViewDelegate -
extension LibraryController: UICollectionViewDelegate {
  //При нажатии на обьект переходим на TutorialDetailController, мы это сделали без сегвея внутри кода
  //Мы указали Storyboard_ID в Main.storyboard в самом TutorialDetailController
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let tutorial = dataSource.itemIdentifier(for: indexPath), let tutorialDetailController = storyboard?.instantiateViewController(identifier: TutorialDetailViewController.identifier, creator: {
      return TutorialDetailViewController(coder: $0, tutorial: tutorial)
    }) {
      show(tutorialDetailController, sender: nil)
    }
  }
}
