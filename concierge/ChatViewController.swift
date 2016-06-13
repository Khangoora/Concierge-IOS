

import UIKit
import Foundation

class ChatViewController: JSQMessagesViewController {
    
    var user: PFUser!
    var gameId: String!
    var players: [Player]!
    
    var messages = [Message]()
    var avatars = Dictionary<String, UIImage>()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleGreenColor())
    var senderImageUrl: String!
    var batchMessages = true
    var ref: Firebase!
    
    var messagesRef: Firebase!
    
    func setupFirebase() {
        messagesRef = Firebase(url: "https://sportsconcierge.firebaseio.com/messages/\(gameId)")
        
        messagesRef.queryLimitedToLast(25).observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) in
            let text = snapshot.value["text"] as? String
            let sender = snapshot.value["sender"] as? String
            let imageUrl = snapshot.value["imageUrl"] as? String
            
            let message = Message(text: text, sender: sender, imageUrl: imageUrl)
            self.messages.append(message)
            self.finishReceivingMessage()
        })
    }
    
    
    @IBAction func dismissTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func sendMessage(text: String!, sender: String!) {
        messagesRef.childByAutoId().setValue([
            "text":text,
            "sender":sender,
            "imageUrl":senderImageUrl
            ])
        
        let firstName = PFUser.currentUser()!.valueForKey("first_name") as! String
        let lastName = PFUser.currentUser()!.valueForKey("last_name") as! String
        
        for player in players {
            let message = "\(firstName) \(lastName): \(text)"
            if (player.objectId != PFUser.currentUser()!.objectId!) {
                sendNotification(player.object, message: message)
            }
        }
    }
    
    func tempSendMessage(text: String!, sender: String!) {
        let message = Message(text: text, sender: sender, imageUrl: senderImageUrl)
        messages.append(message)
    }
    
    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
        if let stringUrl = imageUrl {
            if let url = NSURL(string: stringUrl) {
                if let data = NSData(contentsOfURL: url) {
                    let image = UIImage(data: data)
                    let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
                    let avatarImage = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: diameter)
                    avatars[name] = avatarImage
                    return
                }
            }
        }
        
        setupAvatarColor(name, incoming: incoming)
    }
    
    func setupAvatarColor(name: String, incoming: Bool) {
        let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
        
        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        
        let nameLength = name.characters.count
        let initials : String? = name.substringToIndex(sender.startIndex.advancedBy(min(3, nameLength)))
        let userImage = JSQMessagesAvatarFactory.avatarWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
        
        avatars[name] = userImage
    }
    
    override func viewDidDisappear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = CoreViewController.primaryGreenColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        user = PFUser.currentUser()!
        inputToolbar.contentView.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        
        let first_name = user.valueForKey("first_name") != nil ? user.valueForKey("first_name") as! String : "Anonymous"
        let last_name = user.valueForKey("last_name") != nil ? user.valueForKey("last_name") as! String : "User"
        sender = "\(first_name) \(last_name)"
        let profileImageUrl = user.valueForKey("image_url") as? NSString
        if let urlString = profileImageUrl {
            setupAvatarImage(sender, imageUrl: urlString as String, incoming: false)
            senderImageUrl = urlString as String
        } else {
            setupAvatarColor(sender, incoming: false)
            senderImageUrl = ""
        }
        
        setupFirebase()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.hidden = false
        collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.hidden = true
        
        
        if ref != nil {
            ref.unauth()
        }
    }
    
    func receivedMessagePressed(sender: UIBarButtonItem) {
        showTypingIndicator = !showTypingIndicator
        scrollToBottomAnimated(true)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, sender: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        sendMessage(text, sender: sender)
        
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("Camera pressed!")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        let message = messages[indexPath.item]
        
        if message.sender() == sender {
            return UIImageView(image: outgoingBubbleImageView.image, highlightedImage: outgoingBubbleImageView.highlightedImage)
        }
        
        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        let message = messages[indexPath.item]
        if let avatar = avatars[message.sender()] {
            return UIImageView(image: avatar)
        } else {
            setupAvatarImage(message.sender(), imageUrl: message.imageUrl(), incoming: true)
            return UIImageView(image:avatars[message.sender()])
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        if message.sender() == sender {
            cell.textView.textColor = UIColor.blackColor()
        } else {
            cell.textView.textColor = UIColor.whiteColor()
        }
        
        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
        return cell
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.item];
        
        if message.sender() == sender {
            return nil;
        }
        
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sender() == message.sender() {
                return nil;
            }
        }
        
        return NSAttributedString(string:message.sender())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        if message.sender() == sender {
            return CGFloat(0.0);
        }
        
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.sender() == message.sender() {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    func sendNotification(receiver: PFObject, message: String) {
        let query = PFInstallation.query()
        query?.whereKey("user", equalTo: receiver)
        let push = PFPush()
        push.setQuery(query)
        let data = [
            "alert" : message,
            "sound" : "default"
        ]
        push.setData(data)
        push.sendPushInBackground()
    }

}
