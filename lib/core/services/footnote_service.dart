import 'package:flutter/foundation.dart';
import 'dart:convert';

/// Comprehensive footnote service for providing verse footnotes and cross-references
class FootnoteService {
  static final FootnoteService _instance = FootnoteService._internal();
  factory FootnoteService() => _instance;
  FootnoteService._internal();
  
  // Footnote database - maps verse IDs to footnotes
  final Map<String, List<Footnote>> _footnotes = {};
  final Map<String, List<CrossReference>> _crossReferences = {};
  
  bool _initialized = false;
  
  /// Initialize footnote data
  Future<void> initialize() async {
    if (_initialized) return;
    
    await _loadFootnotes();
    _initialized = true;
  }
  
  Future<void> _loadFootnotes() async {
    _footnotes.addAll({
      // ============================================
      // GENESIS
      // ============================================
      'GEN 1:1': [
        Footnote(id: '1', text: 'Hebrew: "In beginning" - The definite article is absent, indicating the absolute beginning of time and creation.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"God" - Hebrew "Elohim" (plural form) suggesting plurality in the Godhead, used with singular verbs indicating unity.', type: FootnoteType.theological),
        Footnote(id: '3', text: '"created" - Hebrew "bara", used exclusively for divine creation, indicating creation ex nihilo (out of nothing).', type: FootnoteType.linguistic),
      ],
      'GEN 1:2': [
        Footnote(id: '1', text: '"without form, and void" - Hebrew "tohu wabohu", describing chaos before God\'s ordering work.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"Spirit of God" - Hebrew "Ruach Elohim", also translated "wind from God" or "mighty wind".', type: FootnoteType.translation),
        Footnote(id: '3', text: '"moved" - Hebrew "rachaph", to hover or brood over, like a bird over its nest.', type: FootnoteType.linguistic),
      ],
      'GEN 1:3': [
        Footnote(id: '1', text: '"Let there be light" - God\'s first creative word, demonstrating the power of divine speech.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Light created before the sun (day 4), showing God is the source of all light.', type: FootnoteType.interpretation),
      ],
      'GEN 1:26': [
        Footnote(id: '1', text: '"Let us make" - The plural pronoun may indicate the Trinity or the heavenly council of angels.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"image" - Hebrew "tselem", meaning resemblance or representation. Humans reflect God\'s character.', type: FootnoteType.linguistic),
        Footnote(id: '3', text: '"likeness" - Hebrew "demuth", similitude or resemblance.', type: FootnoteType.linguistic),
      ],
      'GEN 1:27': [
        Footnote(id: '1', text: '"male and female" - Both genders equally bear God\'s image, establishing human dignity.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'The Hebrew poetic structure emphasizes the completeness of humanity in both genders.', type: FootnoteType.linguistic),
      ],
      'GEN 2:7': [
        Footnote(id: '1', text: '"dust" - Hebrew "aphar", indicating man\'s humble origin from the ground.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"breath of life" - Hebrew "neshamah", the life-giving breath of God.', type: FootnoteType.theological),
        Footnote(id: '3', text: '"living soul" - Hebrew "nephesh chayyah", a living being.', type: FootnoteType.linguistic),
      ],
      'GEN 2:24': [
        Footnote(id: '1', text: '"leave his father and his mother" - The establishment of marriage as a new primary relationship.', type: FootnoteType.cultural),
        Footnote(id: '2', text: '"one flesh" - The marital union creates a new indivisible unit.', type: FootnoteType.theological),
        Footnote(id: '3', text: 'Quoted by Jesus in Matthew 19:5 and Mark 10:7-8 as the foundation of marriage.', type: FootnoteType.crossReference),
      ],
      'GEN 3:15': [
        Footnote(id: '1', text: 'Called the "Protoevangelium" - the first gospel promise of Christ\'s victory over Satan.', type: FootnoteType.messianic),
        Footnote(id: '2', text: '"bruise thy head" - A fatal blow, indicating ultimate victory over the serpent.', type: FootnoteType.interpretation),
        Footnote(id: '3', text: '"bruise his heel" - A non-fatal blow, indicating Christ\'s suffering on the cross.', type: FootnoteType.interpretation),
      ],
      'GEN 3:16': [
        Footnote(id: '1', text: '"sorrow" - Hebrew "itstsabown", pain, toil, or sorrow in conception and childbirth.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"desire" - Hebrew "teshuqah", longing or desire for one\'s husband.', type: FootnoteType.linguistic),
      ],
      'GEN 12:1': [
        Footnote(id: '1', text: '"Get thee out" - The call of Abram begins with a command to leave everything familiar.', type: FootnoteType.historical),
        Footnote(id: '2', text: 'Abram\'s journey of faith begins at age 75 (Genesis 12:4).', type: FootnoteType.historical),
      ],
      'GEN 12:2': [
        Footnote(id: '1', text: '"I will make of thee a great nation" - The first of three promises: nation, blessing, name.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"be thou a blessing" - Abram is not just to receive blessing but to be a source of it.', type: FootnoteType.interpretation),
      ],
      'GEN 15:6': [
        Footnote(id: '1', text: '"believed" - Hebrew "aman", to trust, rely upon. The root of "Amen".', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"counted it to him for righteousness" - Hebrew "chashab", imputed or credited.', type: FootnoteType.linguistic),
        Footnote(id: '3', text: 'Key verse for justification by faith (Romans 4:3, Galatians 3:6, James 2:23).', type: FootnoteType.crossReference),
      ],
      'GEN 22:8': [
        Footnote(id: '1', text: '"God will provide himself a lamb" - Hebrew "jireh", to see or provide.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: 'Prophetic of God providing Christ as the Lamb of God (John 1:29).', type: FootnoteType.messianic),
        Footnote(id: '3', text: 'The place becomes known as "Jehovah Jireh" - The Lord Will Provide.', type: FootnoteType.theological),
      ],
      
      // ============================================
      // EXODUS
      // ============================================
      'EXO 3:14': [
        Footnote(id: '1', text: '"I AM THAT I AM" - Hebrew "Ehyeh Asher Ehyeh", the self-existent, eternal God.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: 'Related to the divine name YHWH (Yahweh/Jehovah), meaning "He is".', type: FootnoteType.theological),
        Footnote(id: '3', text: 'Jesus applies this title to himself in John 8:58: "Before Abraham was, I am."', type: FootnoteType.messianic),
      ],
      'EXO 20:3': [
        Footnote(id: '1', text: 'First Commandment: The foundation of all others - exclusive worship of Yahweh.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"before me" - Hebrew "al panay", literally "before my face" or "in my presence".', type: FootnoteType.linguistic),
      ],
      'EXO 20:7': [
        Footnote(id: '1', text: 'Third Commandment: Prohibits taking God\'s name in vain or for false purposes.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"vain" - Hebrew "shav", emptiness, falsehood, or worthlessness.', type: FootnoteType.linguistic),
      ],
      'EXO 20:13': [
        Footnote(id: '1', text: 'Sixth Commandment: "Thou shalt not kill" - Hebrew "ratsach", murder, not all killing.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: 'Prohibits unlawful killing, premeditated murder.', type: FootnoteType.interpretation),
      ],
      'EXO 34:6': [
        Footnote(id: '1', text: 'God\'s self-revelation: "merciful and gracious, longsuffering, and abundant in goodness and truth."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'This description of God is quoted throughout Scripture (Psalm 86:15, 103:8, 145:8).', type: FootnoteType.crossReference),
      ],
      
      // ============================================
      // LEVITICUS
      // ============================================
      'LEV 19:18': [
        Footnote(id: '1', text: '"Thou shalt love thy neighbour as thyself" - The second great commandment.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Quoted by Jesus as one of the two greatest commandments (Matthew 22:39).', type: FootnoteType.crossReference),
        Footnote(id: '3', text: 'The Hebrew word for love here is "ahav" - active, practical love.', type: FootnoteType.linguistic),
      ],
      
      // ============================================
      // NUMBERS
      // ============================================
      'NUM 6:24': [
        Footnote(id: '1', text: 'The Aaronic Blessing begins: "The LORD bless thee, and keep thee."', type: FootnoteType.cultural),
        Footnote(id: '2', text: 'This priestly blessing is still used in Jewish and Christian worship today.', type: FootnoteType.historical),
      ],
      
      // ============================================
      // DEUTERONOMY
      // ============================================
      'DEU 6:4': [
        Footnote(id: '1', text: 'The Shema: "Hear, O Israel: The LORD our God is one LORD."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Jewish confession of faith, recited twice daily by devout Jews.', type: FootnoteType.cultural),
        Footnote(id: '3', text: '"one" - Hebrew "echad", a compound unity, not solitary oneness.', type: FootnoteType.linguistic),
      ],
      'DEU 6:5': [
        Footnote(id: '1', text: 'The greatest commandment: love God with all your heart, soul, and might.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Quoted by Jesus as the first and greatest commandment (Mark 12:29-30).', type: FootnoteType.crossReference),
        Footnote(id: '3', text: 'Threefold expression: "heart" (will/emotions), "soul" (life), "might" (strength).', type: FootnoteType.interpretation),
      ],
      'DEU 31:6': [
        Footnote(id: '1', text: '"Be strong and of a good courage" - Repeated theme in Joshua (1:6, 7, 9, 18).', type: FootnoteType.crossReference),
        Footnote(id: '2', text: '"he will not fail thee, nor forsake thee" - God\'s presence is the source of courage.', type: FootnoteType.theological),
        Footnote(id: '3', text: 'Quoted in Hebrews 13:5 as a promise for believers.', type: FootnoteType.crossReference),
      ],
      
      // ============================================
      // JOSHUA
      // ============================================
      'JOS 1:8': [
        Footnote(id: '1', text: '"meditate" - Hebrew "hagah", to murmur, ponder, meditate day and night.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: 'Success comes from constant engagement with God\'s Word.', type: FootnoteType.interpretation),
      ],
      'JOS 24:15': [
        Footnote(id: '1', text: '"choose you this day whom ye will serve" - The call to deliberate commitment.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"as for me and my house, we will serve the LORD" - Joshua\'s personal declaration of faith.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // JUDGES
      // ============================================
      'JDG 6:12': [
        Footnote(id: '1', text: '"The LORD is with thee, thou mighty man of valour" - God\'s call to Gideon.', type: FootnoteType.historical),
        Footnote(id: '2', text: 'God sees potential and courage where Gideon sees weakness.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // RUTH
      // ============================================
      'RUT 1:16': [
        Footnote(id: '1', text: '"Entreat me not to leave thee" - Ruth\'s famous declaration of loyalty.', type: FootnoteType.historical),
        Footnote(id: '2', text: '"thy people shall be my people, and thy God my God" - Conversion and covenant loyalty.', type: FootnoteType.theological),
        Footnote(id: '3', text: 'Ruth becomes an ancestor of David and Jesus (Matthew 1:5).', type: FootnoteType.messianic),
      ],
      
      // ============================================
      // 1 SAMUEL
      // ============================================
      '1SA 16:7': [
        Footnote(id: '1', text: '"look not on his countenance" - God sees beyond outward appearance.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"the LORD looketh on the heart" - God evaluates character, not externals.', type: FootnoteType.interpretation),
        Footnote(id: '3', text: 'This principle guides God\'s choice of David as king.', type: FootnoteType.historical),
      ],
      
      // ============================================
      // 2 SAMUEL
      // ============================================
      '2SA 7:12': [
        Footnote(id: '1', text: 'The Davidic Covenant: God promises David an eternal dynasty.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Fulfilled ultimately in Jesus Christ, the Son of David (Matthew 1:1).', type: FootnoteType.messianic),
      ],
      
      // ============================================
      // 1 KINGS
      // ============================================
      '1KI 18:21': [
        Footnote(id: '1', text: '"How long halt ye between two opinions?" - Elijah\'s challenge to Israel.', type: FootnoteType.historical),
        Footnote(id: '2', text: '"if the LORD be God, follow him" - The call to wholehearted commitment.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // 2 KINGS
      // ============================================
      '2KI 6:16': [
        Footnote(id: '1', text: '"Fear not: for they that be with us are more than they that be with them."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Elisha\'s servant sees the heavenly army protecting them (verse 17).', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // 2 CHRONICLES
      // ============================================
      '2CH 7:14': [
        Footnote(id: '1', text: '"If my people" - The condition for national revival begins with God\'s people.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"humble themselves, and pray" - Four actions: humble, pray, seek, turn.', type: FootnoteType.theological),
        Footnote(id: '3', text: '"heal their land" - God promises restoration in response to repentance.', type: FootnoteType.theological),
      ],
      
      // ============================================
      // EZRA
      // ============================================
      'EZR 9:6': [
        Footnote(id: '1', text: '"O my God, I am ashamed and blush to lift up my face to thee" - Ezra\'s prayer of confession.', type: FootnoteType.historical),
        Footnote(id: '2', text: 'Ezra leads national repentance for intermarriage with foreign peoples.', type: FootnoteType.historical),
      ],
      
      // ============================================
      // NEHEMIAH
      // ============================================
      'NEH 8:10': [
        Footnote(id: '1', text: '"The joy of the LORD is your strength" - Spiritual joy empowers believers.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Context: The people weep hearing the Law, but are encouraged to celebrate.', type: FootnoteType.historical),
      ],
      
      // ============================================
      // ESTHER
      // ============================================
      'EST 4:14': [
        Footnote(id: '1', text: '"who knoweth whether thou art come to the kingdom for such a time as this?"', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Mordecai\'s challenge to Esther to risk her life for her people.', type: FootnoteType.historical),
        Footnote(id: '3', text: 'God is never mentioned in Esther, but His providence is evident throughout.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // JOB
      // ============================================
      'JOB 1:21': [
        Footnote(id: '1', text: '"The LORD gave, and the LORD hath taken away" - Job\'s response to tragedy.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"blessed be the name of the LORD" - Worship in suffering.', type: FootnoteType.interpretation),
      ],
      'JOB 19:25': [
        Footnote(id: '1', text: '"For I know that my redeemer liveth" - Job\'s declaration of faith in resurrection.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"Redeemer" - Hebrew "goel", kinsman-redeemer who vindicates.', type: FootnoteType.linguistic),
        Footnote(id: '3', text: 'One of the clearest Old Testament references to resurrection.', type: FootnoteType.interpretation),
      ],
      'JOB 42:5': [
        Footnote(id: '1', text: '"I have heard of thee by the hearing of the ear: but now mine eye seeth thee."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Job moves from secondhand knowledge to personal encounter with God.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // PSALMS
      // ============================================
      'PSA 1:1': [
        Footnote(id: '1', text: '"Blessed is the man" - Hebrew "ashrey", happy or blessed.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: 'Three negative steps: walk not, stand not, sit not - progression of sin.', type: FootnoteType.interpretation),
      ],
      'PSA 1:2': [
        Footnote(id: '1', text: '"delight" - Hebrew "chephets", pleasure, desire, longing.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"meditate day and night" - Constant reflection on God\'s Word.', type: FootnoteType.interpretation),
      ],
      'PSA 19:1': [
        Footnote(id: '1', text: '"The heavens declare the glory of God" - Natural revelation of God.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Quoted in Romans 1:20 as evidence of God\'s existence.', type: FootnoteType.crossReference),
      ],
      'PSA 22:1': [
        Footnote(id: '1', text: '"My God, my God, why hast thou forsaken me?" - A messianic psalm.', type: FootnoteType.messianic),
        Footnote(id: '2', text: 'Jesus quotes this on the cross (Matthew 27:46).', type: FootnoteType.crossReference),
        Footnote(id: '3', text: 'Psalm 22 describes crucifixion in detail before it was invented.', type: FootnoteType.messianic),
      ],
      'PSA 23:1': [
        Footnote(id: '1', text: '"The LORD is my shepherd" - "LORD" in capitals represents YHWH (Yahweh).', type: FootnoteType.translation),
        Footnote(id: '2', text: 'David uses the shepherd metaphor from his own experience (1 Samuel 16:11).', type: FootnoteType.historical),
        Footnote(id: '3', text: '"I shall not want" - God provides all needs, not all wants.', type: FootnoteType.interpretation),
      ],
      'PSA 23:4': [
        Footnote(id: '1', text: '"valley of the shadow of death" - Hebrew "tsalmaveth", deep darkness or deadly danger.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"rod and staff" - Tools of the shepherd for protection and guidance.', type: FootnoteType.cultural),
        Footnote(id: '3', text: '"thou art with me" - The turning point of the psalm, addressing God directly.', type: FootnoteType.theological),
      ],
      'PSA 32:1': [
        Footnote(id: '1', text: '"Blessed is he whose transgression is forgiven" - The joy of forgiveness.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Quoted by Paul in Romans 4:7-8 to teach justification by faith.', type: FootnoteType.crossReference),
      ],
      'PSA 37:4': [
        Footnote(id: '1', text: '"Delight thyself also in the LORD" - Find your joy in God alone.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"he shall give thee the desires of thine heart" - When God is your delight, His desires become yours.', type: FootnoteType.theological),
      ],
      'PSA 46:1': [
        Footnote(id: '1', text: '"God is our refuge and strength" - Three descriptions: refuge, strength, help.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"a very present help in trouble" - God is accessible and ready to help.', type: FootnoteType.interpretation),
      ],
      'PSA 46:10': [
        Footnote(id: '1', text: '"Be still, and know that I am God" - Hebrew "raphah", to let go, relax, cease striving.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: 'God\'s sovereignty calls for human trust and rest.', type: FootnoteType.theological),
      ],
      'PSA 51:10': [
        Footnote(id: '1', text: '"Create in me a clean heart" - Hebrew "bara", only God can create.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: 'David\'s prayer of repentance after his sin with Bathsheba.', type: FootnoteType.historical),
        Footnote(id: '3', text: '"renew a right spirit" - Hebrew "chadash", to make new or repair.', type: FootnoteType.linguistic),
      ],
      'PSA 91:1': [
        Footnote(id: '1', text: '"secret place" - Hebrew "sether", a hiding place or shelter.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"Almighty" - Hebrew "Shaddai", the All-Sufficient One.', type: FootnoteType.translation),
        Footnote(id: '3', text: 'Psalm 91 is known as the "Soldier\'s Psalm" for protection.', type: FootnoteType.cultural),
      ],
      'PSA 100:4': [
        Footnote(id: '1', text: '"Enter into his gates with thanksgiving" - Approach to God begins with gratitude.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"courts" - The temple courts, the place of worship.', type: FootnoteType.cultural),
      ],
      'PSA 119:11': [
        Footnote(id: '1', text: '"Thy word have I hid in mine heart" - Memorization and internalization of Scripture.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"that I might not sin against thee" - Scripture as a defense against sin.', type: FootnoteType.theological),
      ],
      'PSA 119:105': [
        Footnote(id: '1', text: '"Thy word is a lamp unto my feet, and a light unto my path."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Scripture provides guidance for daily decisions and life direction.', type: FootnoteType.interpretation),
      ],
      'PSA 139:14': [
        Footnote(id: '1', text: '"I will praise thee; for I am fearfully and wonderfully made."', type: FootnoteType.theological),
        Footnote(id: '2', text: '"marvellous are thy works" - Human life is a divine work of art.', type: FootnoteType.interpretation),
      ],
      'PSA 145:18': [
        Footnote(id: '1', text: '"The LORD is nigh unto all them that call upon him" - God\'s nearness to the praying.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"to all that call upon him in truth" - Sincere, genuine prayer.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // PROVERBS
      // ============================================
      'PRO 1:7': [
        Footnote(id: '1', text: '"The fear of the LORD is the beginning of knowledge" - Reverence for God is foundational.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"fools despise wisdom and instruction" - The contrast between wise and foolish.', type: FootnoteType.interpretation),
      ],
      'PRO 3:5': [
        Footnote(id: '1', text: '"Trust in the LORD with all thine heart" - Complete reliance on God.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"lean not unto thine own understanding" - Human wisdom is limited.', type: FootnoteType.interpretation),
      ],
      'PRO 3:6': [
        Footnote(id: '1', text: '"In all thy ways acknowledge him" - Include God in every decision.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"he shall direct thy paths" - God promises guidance.', type: FootnoteType.theological),
      ],
      'PRO 4:23': [
        Footnote(id: '1', text: '"Keep thy heart with all diligence" - Hebrew "natsar", to guard, watch over.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"out of it are the issues of life" - The heart is the source of all actions.', type: FootnoteType.theological),
      ],
      'PRO 9:10': [
        Footnote(id: '1', text: '"The fear of the LORD is the beginning of wisdom" - Repeated theme (1:7).', type: FootnoteType.theological),
        Footnote(id: '2', text: '"knowledge of the holy is understanding" - Knowing God equals understanding.', type: FootnoteType.interpretation),
      ],
      'PRO 16:3': [
        Footnote(id: '1', text: '"Commit thy works unto the LORD" - Hebrew "galal", to roll onto.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"thy thoughts shall be established" - God aligns plans with His purposes.', type: FootnoteType.theological),
      ],
      'PRO 22:6': [
        Footnote(id: '1', text: '"Train up a child in the way he should go" - Hebrew "chanak", to dedicate or initiate.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"when he is old, he will not depart from it" - Early training has lasting impact.', type: FootnoteType.interpretation),
      ],
      'PRO 27:17': [
        Footnote(id: '1', text: '"Iron sharpeneth iron; so a man sharpeneth the countenance of his friend."', type: FootnoteType.interpretation),
        Footnote(id: '2', text: 'Friendship and fellowship improve both parties through interaction.', type: FootnoteType.interpretation),
      ],
      'PRO 29:18': [
        Footnote(id: '1', text: '"Where there is no vision, the people perish" - Hebrew "chazon", divine revelation.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"he that keepeth the law, happy is he" - Blessing comes through obedience.', type: FootnoteType.theological),
      ],
      'PRO 31:10': [
        Footnote(id: '1', text: '"Who can find a virtuous woman?" - Hebrew "chayil", strength, capability, valor.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: 'The Proverbs 31 woman is an ideal, not a checklist.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // ECCLESIASTES
      // ============================================
      'ECC 1:2': [
        Footnote(id: '1', text: '"Vanity of vanities" - Hebrew "hebel", vapor, breath, emptiness.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: 'Life without God is meaningless and temporary.', type: FootnoteType.interpretation),
      ],
      'ECC 3:1': [
        Footnote(id: '1', text: '"To every thing there is a season, and a time to every purpose under the heaven."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'God sovereignly ordains times and seasons.', type: FootnoteType.theological),
      ],
      'ECC 12:1': [
        Footnote(id: '1', text: '"Remember now thy Creator in the days of thy youth" - Seek God early in life.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: 'The conclusion of Ecclesiastes: Fear God and keep His commandments (12:13).', type: FootnoteType.theological),
      ],
      
      // ============================================
      // SONG OF SOLOMON
      // ============================================
      'SOS 2:4': [
        Footnote(id: '1', text: '"He brought me to the banqueting house" - Hebrew "beth hayyayin", house of wine.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: 'Often interpreted allegorically of Christ\'s love for the church.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // ISAIAH
      // ============================================
      'ISA 1:18': [
        Footnote(id: '1', text: '"Come now, and let us reason together" - God invites dialogue.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"scarlet... crimson" - Deep red stains representing sin.', type: FootnoteType.linguistic),
        Footnote(id: '3', text: '"white as snow" - Complete cleansing and forgiveness.', type: FootnoteType.interpretation),
      ],
      'ISA 6:3': [
        Footnote(id: '1', text: '"Holy, holy, holy" - The threefold holiness of God (trisagion).', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Quoted in Revelation 4:8 as the heavenly worship.', type: FootnoteType.crossReference),
        Footnote(id: '3', text: '"the whole earth is full of his glory" - God\'s presence fills creation.', type: FootnoteType.theological),
      ],
      'ISA 7:14': [
        Footnote(id: '1', text: '"virgin" - Hebrew "almah", young woman of marriageable age. Septuagint translates "parthenos" (virgin).', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"Immanuel" - "God with us", quoted in Matthew 1:23 as fulfilled in Christ.', type: FootnoteType.messianic),
      ],
      'ISA 9:6': [
        Footnote(id: '1', text: '"Wonderful, Counsellor" - Or "Wonderful Counsellor", a single title.', type: FootnoteType.translation),
        Footnote(id: '2', text: '"mighty God" - Hebrew "El Gibbor", the same title used for Yahweh in 10:21.', type: FootnoteType.theological),
        Footnote(id: '3', text: '"Prince of Peace" - Hebrew "Sar Shalom", bringer of wholeness and peace.', type: FootnoteType.messianic),
      ],
      'ISA 40:31': [
        Footnote(id: '1', text: '"wait upon the LORD" - Hebrew "qavah", to wait with hope and expectation.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"renew their strength" - Hebrew "chalaph", to exchange or replace.', type: FootnoteType.linguistic),
        Footnote(id: '3', text: '"mount up with wings as eagles" - Soar above circumstances.', type: FootnoteType.interpretation),
      ],
      'ISA 53:3': [
        Footnote(id: '1', text: '"despised and rejected of men" - The suffering servant is rejected.', type: FootnoteType.messianic),
        Footnote(id: '2', text: '"man of sorrows" - Hebrew "ish makhovoth", acquainted with grief.', type: FootnoteType.linguistic),
      ],
      'ISA 53:5': [
        Footnote(id: '1', text: '"wounded" - Hebrew "chalal", pierced or defiled.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"stripes" - Hebrew "chabburah", bruises from beating.', type: FootnoteType.linguistic),
        Footnote(id: '3', text: '"by his stripes we are healed" - Physical and spiritual healing through Christ\'s suffering.', type: FootnoteType.messianic),
      ],
      'ISA 53:6': [
        Footnote(id: '1', text: '"All we like sheep have gone astray" - Universal human wandering.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"the LORD hath laid on him the iniquity of us all" - Substitutionary atonement.', type: FootnoteType.theological),
      ],
      'ISA 55:8': [
        Footnote(id: '1', text: '"For my thoughts are not your thoughts" - God\'s wisdom transcends human understanding.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Divine transcendence: God\'s ways are higher than ours.', type: FootnoteType.interpretation),
      ],
      'ISA 55:11': [
        Footnote(id: '1', text: '"my word... shall not return unto me void" - God\'s Word always accomplishes its purpose.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Scripture is effective and powerful, never wasted.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // JEREMIAH
      // ============================================
      'JER 1:5': [
        Footnote(id: '1', text: '"Before I formed thee... I knew thee" - God\'s foreknowledge and predestination.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"sanctified thee" - Set apart for holy purpose before birth.', type: FootnoteType.theological),
        Footnote(id: '3', text: 'Support for God\'s knowledge of persons before birth.', type: FootnoteType.interpretation),
      ],
      'JER 29:11': [
        Footnote(id: '1', text: '"For I know the thoughts that I think toward you" - God\'s good plans.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"thoughts" - Hebrew "machashabah", plans, purposes, intentions.', type: FootnoteType.linguistic),
        Footnote(id: '3', text: '"peace, and not of evil" - Hebrew "shalom", wholeness, prosperity, peace.', type: FootnoteType.linguistic),
      ],
      'JER 31:33': [
        Footnote(id: '1', text: '"I will put my law in their inward parts" - The new covenant promise.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Internal transformation, not external law-keeping.', type: FootnoteType.interpretation),
        Footnote(id: '3', text: 'Quoted in Hebrews 8:10 and 10:16 as fulfilled in Christ.', type: FootnoteType.crossReference),
      ],
      'JER 33:3': [
        Footnote(id: '1', text: '"Call unto me, and I will answer thee" - God\'s invitation to prayer.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"shew thee great and mighty things" - Hebrew "gadol", inaccessible things.', type: FootnoteType.linguistic),
      ],
      
      // ============================================
      // LAMENTATIONS
      // ============================================
      'LAM 3:22': [
        Footnote(id: '1', text: '"It is of the LORD\'S mercies that we are not consumed" - God\'s covenant loyalty.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"mercies" - Hebrew "chesed", steadfast love, covenant faithfulness.', type: FootnoteType.linguistic),
      ],
      'LAM 3:23': [
        Footnote(id: '1', text: '"They are new every morning" - Fresh grace for each day.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"great is thy faithfulness" - God\'s reliability never fails.', type: FootnoteType.theological),
      ],
      
      // ============================================
      // EZEKIEL
      // ============================================
      'EZK 36:26': [
        Footnote(id: '1', text: '"A new heart also will I give you" - Spiritual regeneration promised.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"stony heart" - Hard, unresponsive heart removed.', type: FootnoteType.interpretation),
        Footnote(id: '3', text: '"heart of flesh" - Living, responsive heart given.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // DANIEL
      // ============================================
      'DAN 3:17': [
        Footnote(id: '1', text: '"Our God whom we serve is able to deliver us" - Faith in God\'s power.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'The three Hebrews\' declaration before the fiery furnace.', type: FootnoteType.historical),
      ],
      'DAN 6:10': [
        Footnote(id: '1', text: '"he kneeled upon his knees three times a day" - Daniel\'s prayer discipline.', type: FootnoteType.cultural),
        Footnote(id: '2', text: 'Prayer "toward Jerusalem" - Following Solomon\'s example (1 Kings 8:48).', type: FootnoteType.crossReference),
      ],
      
      // ============================================
      // HOSEA
      // ============================================
      'HOS 6:6': [
        Footnote(id: '1', text: '"For I desired mercy, and not sacrifice" - God values relationship over ritual.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Quoted twice by Jesus (Matthew 9:13, 12:7).', type: FootnoteType.crossReference),
      ],
      
      // ============================================
      // JOEL
      // ============================================
      'JOL 2:28': [
        Footnote(id: '1', text: '"I will pour out my spirit upon all flesh" - The promise of the Spirit.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Fulfilled at Pentecost (Acts 2:17-21).', type: FootnoteType.crossReference),
      ],
      
      // ============================================
      // AMOS
      // ============================================
      'AMO 3:3': [
        Footnote(id: '1', text: '"Can two walk together, except they be agreed?" - Unity requires agreement.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: 'Rhetorical question emphasizing fellowship with God.', type: FootnoteType.theological),
      ],
      
      // ============================================
      // JONAH
      // ============================================
      'JON 2:2': [
        Footnote(id: '1', text: '"I cried by reason of mine affliction unto the LORD" - Jonah\'s prayer from the fish.', type: FootnoteType.historical),
        Footnote(id: '2', text: 'Jonah\'s experience foreshadows Christ\'s three days in the tomb (Matthew 12:40).', type: FootnoteType.messianic),
      ],
      
      // ============================================
      // MICAH
      // ============================================
      'MIC 6:8': [
        Footnote(id: '1', text: '"what doth the LORD require of thee" - Three requirements: justice, mercy, humility.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"do justly" - Hebrew "mishpat", justice, righteousness.', type: FootnoteType.linguistic),
        Footnote(id: '3', text: '"walk humbly" - Hebrew "tsana", to be modest, humble.', type: FootnoteType.linguistic),
      ],
      
      // ============================================
      // HABAKKUK
      // ============================================
      'HAB 2:4': [
        Footnote(id: '1', text: '"the just shall live by his faith" - A key verse for Protestant Reformation.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Quoted three times in NT (Romans 1:17, Galatians 3:11, Hebrews 10:38).', type: FootnoteType.crossReference),
      ],
      
      // ============================================
      // ZEPHANIAH
      // ============================================
      'ZEP 3:17': [
        Footnote(id: '1', text: '"The LORD thy God in the midst of thee is mighty" - God\'s presence and power.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"he will rejoice over thee with joy" - God delights in His people.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // HAGGAI
      // ============================================
      'HAG 1:7': [
        Footnote(id: '1', text: '"Consider your ways" - Hebrew "suwm", to set, place, consider.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: 'Call to examine priorities in light of God\'s purposes.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // ZECHARIAH
      // ============================================
      'ZEC 4:6': [
        Footnote(id: '1', text: '"Not by might, nor by power, but by my Spirit" - Divine enablement.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"might" - Hebrew "chayil", army, strength, wealth.', type: FootnoteType.linguistic),
        Footnote(id: '3', text: '"power" - Hebrew "koach", human capability.', type: FootnoteType.linguistic),
      ],
      
      // ============================================
      // MALACHI
      // ============================================
      'MAL 3:10': [
        Footnote(id: '1', text: '"Bring ye all the tithes into the storehouse" - The principle of tithing.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"prove me now herewith" - God invites us to test His faithfulness.', type: FootnoteType.interpretation),
        Footnote(id: '3', text: '"windows of heaven" - Abundant blessing imagery.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // MATTHEW
      // ============================================
      'MAT 1:23': [
        Footnote(id: '1', text: 'Quote from Isaiah 7:14, fulfilled in Jesus\' birth.', type: FootnoteType.crossReference),
        Footnote(id: '2', text: '"Emmanuel... God with us" - The incarnation: God became human.', type: FootnoteType.messianic),
      ],
      'MAT 5:3': [
        Footnote(id: '1', text: '"Blessed are the poor in spirit" - Greek "ptochos", beggarly, completely dependent.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: 'First Beatitude: Recognition of spiritual poverty precedes blessing.', type: FootnoteType.interpretation),
      ],
      'MAT 5:4': [
        Footnote(id: '1', text: '"Blessed are they that mourn" - Mourning over sin and its effects.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"they shall be comforted" - God\'s comfort to the repentant.', type: FootnoteType.theological),
      ],
      'MAT 5:5': [
        Footnote(id: '1', text: '"Blessed are the meek" - Greek "praus", gentle, humble, not weak.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: 'Quote from Psalm 37:11.', type: FootnoteType.crossReference),
      ],
      'MAT 5:6': [
        Footnote(id: '1', text: '"hunger and thirst after righteousness" - Intense spiritual desire.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"they shall be filled" - Greek "chortazo", to be satisfied, fattened.', type: FootnoteType.linguistic),
      ],
      'MAT 5:7': [
        Footnote(id: '1', text: '"Blessed are the merciful" - Showing compassion to others.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"obtain mercy" - We receive what we give (Matthew 6:14-15).', type: FootnoteType.theological),
      ],
      'MAT 5:8': [
        Footnote(id: '1', text: '"pure in heart" - Greek "katharos", clean, unmixed, sincere.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"see God" - Both now by faith and ultimately in glory.', type: FootnoteType.interpretation),
      ],
      'MAT 5:9': [
        Footnote(id: '1', text: '"peacemakers" - Active reconciliation, not passive peace.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"called the children of God" - Reflecting God\'s peacemaking character.', type: FootnoteType.theological),
      ],
      'MAT 5:16': [
        Footnote(id: '1', text: '"Let your light so shine before men" - Visible good works.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"glorify your Father" - Good works point to God, not self.', type: FootnoteType.theological),
      ],
      'MAT 5:17': [
        Footnote(id: '1', text: '"I am not come to destroy, but to fulfil" - Jesus fulfills the Law\'s purpose.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"fulfil" - Greek "pleroo", to fill full, complete, give full meaning.', type: FootnoteType.linguistic),
      ],
      'MAT 5:44': [
        Footnote(id: '1', text: '"Love your enemies" - Revolutionary command, unique to Christianity.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"bless them that curse you" - Responding to evil with good.', type: FootnoteType.interpretation),
      ],
      'MAT 6:9': [
        Footnote(id: '1', text: '"Our Father which art in heaven" - The Lord\'s Prayer begins with relationship.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"Hallowed be thy name" - May Your name be treated as holy.', type: FootnoteType.interpretation),
      ],
      'MAT 6:10': [
        Footnote(id: '1', text: '"Thy kingdom come" - Prayer for God\'s reign to be established.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"Thy will be done" - Submission to God\'s purposes.', type: FootnoteType.interpretation),
      ],
      'MAT 6:11': [
        Footnote(id: '1', text: '"Give us this day our daily bread" - Daily dependence on God for provision.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"daily" - Greek "epiousios", unique word, meaning "sufficient for today."', type: FootnoteType.linguistic),
      ],
      'MAT 6:12': [
        Footnote(id: '1', text: '"Forgive us our debts" - Sins as debts owed to God.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"as we forgive our debtors" - The condition for receiving forgiveness.', type: FootnoteType.theological),
      ],
      'MAT 6:13': [
        Footnote(id: '1', text: '"lead us not into temptation" - Prayer for protection from trials.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"deliver us from evil" - Or "the evil one" - protection from Satan.', type: FootnoteType.translation),
      ],
      'MAT 6:33': [
        Footnote(id: '1', text: '"Seek ye first the kingdom of God" - Priority of God\'s reign.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"his righteousness" - God\'s righteous rule and right standing.', type: FootnoteType.interpretation),
        Footnote(id: '3', text: '"all these things shall be added" - God provides for those who prioritize Him.', type: FootnoteType.theological),
      ],
      'MAT 7:7': [
        Footnote(id: '1', text: '"Ask, and it shall be given you" - Threefold command: ask, seek, knock.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Progressive intensity in prayer: asking, seeking action, knocking persistence.', type: FootnoteType.interpretation),
      ],
      'MAT 7:13': [
        Footnote(id: '1', text: '"wide is the gate, and broad is the way" - The easy path leads to destruction.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"many there be which go in thereat" - The majority choose the wrong path.', type: FootnoteType.theological),
      ],
      'MAT 7:14': [
        Footnote(id: '1', text: '"strait is the gate, and narrow is the way" - The difficult path to life.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"few there be that find it" - Salvation is exclusive and requires intentionality.', type: FootnoteType.theological),
      ],
      'MAT 11:28': [
        Footnote(id: '1', text: '"Come unto me, all ye that labour and are heavy laden" - Jesus\' invitation to the weary.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"I will give you rest" - Greek "anapauso", refreshment, cessation of labor.', type: FootnoteType.linguistic),
      ],
      'MAT 11:29': [
        Footnote(id: '1', text: '"Take my yoke upon you" - Yoke: rabbinic symbol for teaching and discipline.', type: FootnoteType.cultural),
        Footnote(id: '2', text: '"learn of me" - Discipleship means learning from Jesus.', type: FootnoteType.interpretation),
        Footnote(id: '3', text: '"I am meek and lowly in heart" - Jesus models the humility He teaches.', type: FootnoteType.theological),
      ],
      'MAT 16:24': [
        Footnote(id: '1', text: '"If any man will come after me, let him deny himself" - Self-denial required.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"take up his cross" - Willingness to die for Christ.', type: FootnoteType.interpretation),
      ],
      'MAT 22:37': [
        Footnote(id: '1', text: '"Thou shalt love the Lord thy God" - The greatest commandment.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Quote from Deuteronomy 6:5.', type: FootnoteType.crossReference),
        Footnote(id: '3', text: '"heart... soul... mind" - Complete devotion with all one\'s being.', type: FootnoteType.interpretation),
      ],
      'MAT 22:39': [
        Footnote(id: '1', text: '"Thou shalt love thy neighbour as thyself" - The second great commandment.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Quote from Leviticus 19:18.', type: FootnoteType.crossReference),
      ],
      'MAT 24:36': [
        Footnote(id: '1', text: '"But of that day and hour knoweth no man" - The timing of Christ\'s return is unknown.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"no, not the angels of heaven, but my Father only" - Only God the Father knows.', type: FootnoteType.interpretation),
      ],
      'MAT 26:41': [
        Footnote(id: '1', text: '"Watch and pray, that ye enter not into temptation" - Vigilance and prayer.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"the spirit indeed is willing, but the flesh is weak" - Human weakness acknowledged.', type: FootnoteType.interpretation),
      ],
      'MAT 28:18': [
        Footnote(id: '1', text: '"All power is given unto me in heaven and in earth" - Christ\'s universal authority.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'The basis for the Great Commission.', type: FootnoteType.interpretation),
      ],
      'MAT 28:19': [
        Footnote(id: '1', text: '"Go ye therefore, and teach all nations" - The Great Commission.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Trinitarian formula: "Father, Son, and Holy Spirit."', type: FootnoteType.theological),
        Footnote(id: '3', text: '"name" is singular, emphasizing the unity of the three Persons.', type: FootnoteType.linguistic),
      ],
      'MAT 28:20': [
        Footnote(id: '1', text: '"Teaching them to observe all things" - Discipleship includes obedience.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"I am with you alway, even unto the end of the world" - Christ\'s perpetual presence.', type: FootnoteType.theological),
      ],
      
      // ============================================
      // MARK
      // ============================================
      'MRK 8:36': [
        Footnote(id: '1', text: '"For what shall it profit a man, if he shall gain the whole world, and lose his own soul?"', type: FootnoteType.interpretation),
        Footnote(id: '2', text: 'Rhetorical question emphasizing the value of the soul over worldly gain.', type: FootnoteType.theological),
      ],
      'MRK 10:27': [
        Footnote(id: '1', text: '"With men it is impossible, but not with God" - Salvation is humanly impossible.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"for with God all things are possible" - God\'s omnipotence.', type: FootnoteType.theological),
      ],
      'MRK 12:30': [
        Footnote(id: '1', text: '"thou shalt love the Lord thy God with all thy heart" - The greatest commandment.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Mark adds "strength" to the Deuteronomy quotation.', type: FootnoteType.translation),
      ],
      'MRK 16:15': [
        Footnote(id: '1', text: '"Go ye into all the world, and preach the gospel to every creature."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'The universal scope of the gospel message.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // LUKE
      // ============================================
      'LUK 1:37': [
        Footnote(id: '1', text: '"For with God nothing shall be impossible" - God\'s omnipotence.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Greek "ouk adynatesei", literally "no word of God is impossible."', type: FootnoteType.linguistic),
      ],
      'LUK 2:11': [
        Footnote(id: '1', text: '"For unto you is born this day in the city of David a Saviour" - The birth announcement.', type: FootnoteType.messianic),
        Footnote(id: '2', text: '"Christ the Lord" - Messiah and Lord, divine titles.', type: FootnoteType.theological),
      ],
      'LUK 9:23': [
        Footnote(id: '1', text: '"If any man will come after me, let him deny himself" - Daily discipleship.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"take up his cross daily" - Luke emphasizes the ongoing nature of discipleship.', type: FootnoteType.interpretation),
      ],
      'LUK 15:7': [
        Footnote(id: '1', text: '"joy shall be in heaven over one sinner that repenteth" - God\'s joy in salvation.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'The parable of the lost sheep.', type: FootnoteType.interpretation),
      ],
      'LUK 19:10': [
        Footnote(id: '1', text: '"For the Son of man is come to seek and to save that which was lost."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Jesus\' mission statement: seeking and saving the lost.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // JOHN
      // ============================================
      'JHN 1:1': [
        Footnote(id: '1', text: '"In the beginning was the Word" - Greek "en arche", echoing Genesis 1:1.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"Word" - Greek "Logos", the divine expression or reason.', type: FootnoteType.linguistic),
        Footnote(id: '3', text: '"was God" - The Word shares the divine nature: "theos en ho logos."', type: FootnoteType.theological),
      ],
      'JHN 1:3': [
        Footnote(id: '1', text: '"All things were made by him" - Christ\'s role in creation.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"without him was not any thing made that was made" - Comprehensive creation.', type: FootnoteType.interpretation),
      ],
      'JHN 1:12': [
        Footnote(id: '1', text: '"as many as received him" - Faith receives Christ.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"power to become the sons of God" - Greek "exousia", authority, right.', type: FootnoteType.linguistic),
        Footnote(id: '3', text: '"even to them that believe on his name" - Faith in Christ brings adoption.', type: FootnoteType.theological),
      ],
      'JHN 1:14': [
        Footnote(id: '1', text: '"Word was made flesh" - The incarnation: God became human.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"dwelt" - Greek "skenoo", literally "pitched his tent" or "tabernacled."', type: FootnoteType.linguistic),
        Footnote(id: '3', text: '"full of grace and truth" - Jesus embodies God\'s covenant loyalty and faithfulness.', type: FootnoteType.interpretation),
      ],
      'JHN 3:3': [
        Footnote(id: '1', text: '"Except a man be born again" - Greek "gennethe anothen", born from above.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: 'Spiritual rebirth required to see God\'s kingdom.', type: FootnoteType.theological),
      ],
      'JHN 3:5': [
        Footnote(id: '1', text: '"born of water and of the Spirit" - Spiritual cleansing and renewal.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: 'May refer to baptism and Spirit regeneration.', type: FootnoteType.theological),
      ],
      'JHN 3:16': [
        Footnote(id: '1', text: '"so loved" - Greek "houtos agapao", the manner and extent of God\'s love.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"only begotten" - Greek "monogenes", unique, one of a kind.', type: FootnoteType.translation),
        Footnote(id: '3', text: '"whosoever believeth" - Universal invitation with specific condition.', type: FootnoteType.theological),
      ],
      'JHN 3:17': [
        Footnote(id: '1', text: '"For God sent not his Son into the world to condemn the world" - Jesus\' first coming is salvation.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"but that the world through him might be saved" - Salvation is the purpose.', type: FootnoteType.interpretation),
      ],
      'JHN 4:24': [
        Footnote(id: '1', text: '"God is a Spirit" - Greek "pneuma", spirit, non-material being.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"they that worship him must worship him in spirit and in truth" - True worship requirements.', type: FootnoteType.theological),
      ],
      'JHN 5:24': [
        Footnote(id: '1', text: '"He that heareth my word, and believeth on him that sent me" - Faith and hearing.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"hath everlasting life" - Present possession of eternal life.', type: FootnoteType.interpretation),
        Footnote(id: '3', text: '"shall not come into condemnation" - No judgment for believers.', type: FootnoteType.theological),
      ],
      'JHN 6:35': [
        Footnote(id: '1', text: '"I am the bread of life" - First "I AM" statement in John.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"he that cometh to me shall never hunger" - Spiritual satisfaction.', type: FootnoteType.interpretation),
      ],
      'JHN 8:12': [
        Footnote(id: '1', text: '"I am the light of the world" - Second "I AM" statement.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"he that followeth me shall not walk in darkness" - Guidance and truth.', type: FootnoteType.interpretation),
      ],
      'JHN 8:32': [
        Footnote(id: '1', text: '"And ye shall know the truth, and the truth shall make you free."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Truth is personified in Christ (John 14:6).', type: FootnoteType.interpretation),
      ],
      'JHN 8:36': [
        Footnote(id: '1', text: '"If the Son therefore shall make you free, ye shall be free indeed."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'True freedom comes through Christ alone.', type: FootnoteType.interpretation),
      ],
      'JHN 8:58': [
        Footnote(id: '1', text: '"Before Abraham was, I am" - Jesus claims the divine name (Exodus 3:14).', type: FootnoteType.messianic),
        Footnote(id: '2', text: 'Jews understood this as blasphemy (verse 59).', type: FootnoteType.historical),
      ],
      'JHN 10:10': [
        Footnote(id: '1', text: '"I am come that they might have life" - Jesus\' purpose: abundant life.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"more abundantly" - Greek "perisson", overflowing, beyond measure.', type: FootnoteType.linguistic),
      ],
      'JHN 10:11': [
        Footnote(id: '1', text: '"I am the good shepherd" - Third "I AM" statement with metaphor.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"the good shepherd giveth his life for the sheep" - Substitutionary death.', type: FootnoteType.messianic),
      ],
      'JHN 10:27': [
        Footnote(id: '1', text: '"My sheep hear my voice, and I know them, and they follow me."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Threefold relationship: hear, know, follow.', type: FootnoteType.interpretation),
      ],
      'JHN 10:28': [
        Footnote(id: '1', text: '"I give unto them eternal life" - Present possession of eternal life.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"they shall never perish" - Eternal security.', type: FootnoteType.theological),
        Footnote(id: '3', text: '"neither shall any man pluck them out of my hand" - Divine protection.', type: FootnoteType.interpretation),
      ],
      'JHN 11:25': [
        Footnote(id: '1', text: '"I am the resurrection, and the life" - Fifth "I AM" statement.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Jesus is resurrection personified, not just the source.', type: FootnoteType.interpretation),
      ],
      'JHN 14:1': [
        Footnote(id: '1', text: '"Let not your heart be troubled" - Comfort in troubled times.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"ye believe in God, believe also in me" - Faith in Christ equals faith in God.', type: FootnoteType.theological),
      ],
      'JHN 14:6': [
        Footnote(id: '1', text: '"I am the way, the truth, and the life" - Sixth "I AM" statement.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"no man cometh unto the Father, but by me" - Exclusive claim.', type: FootnoteType.theological),
        Footnote(id: '3', text: 'Threefold description: way (access), truth (reality), life (vitality).', type: FootnoteType.interpretation),
      ],
      'JHN 14:13': [
        Footnote(id: '1', text: '"Whatsoever ye shall ask in my name, that will I do" - Prayer in Jesus\' name.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"that the Father may be glorified in the Son" - Prayer\'s purpose: God\'s glory.', type: FootnoteType.interpretation),
      ],
      'JHN 14:15': [
        Footnote(id: '1', text: '"If ye love me, keep my commandments" - Love expressed through obedience.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Love and obedience are inseparable in John\'s theology.', type: FootnoteType.interpretation),
      ],
      'JHN 14:21': [
        Footnote(id: '1', text: '"He that hath my commandments, and keepeth them, he it is that loveth me."', type: FootnoteType.theological),
        Footnote(id: '2', text: '"he that loveth me shall be loved of my Father" - Reciprocal love.', type: FootnoteType.interpretation),
      ],
      'JHN 15:5': [
        Footnote(id: '1', text: '"I am the vine, ye are the branches" - Seventh "I AM" statement.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"without me ye can do nothing" - Absolute dependence on Christ.', type: FootnoteType.interpretation),
      ],
      'JHN 15:7': [
        Footnote(id: '1', text: '"If ye abide in me, and my words abide in you" - Mutual indwelling.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"ye shall ask what ye will, and it shall be done unto you" - Answered prayer.', type: FootnoteType.interpretation),
      ],
      'JHN 15:13': [
        Footnote(id: '1', text: '"Greater love hath no man than this, that a man lay down his life for his friends."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'The supreme expression of love: sacrificial death.', type: FootnoteType.interpretation),
      ],
      'JHN 16:33': [
        Footnote(id: '1', text: '"In the world ye shall have tribulation" - Jesus promises trouble.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"but be of good cheer; I have overcome the world" - Victory in Christ.', type: FootnoteType.interpretation),
      ],
      'JHN 17:3': [
        Footnote(id: '1', text: '"And this is life eternal, that they might know thee the only true God"', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Eternal life is knowing God relationally, not just duration.', type: FootnoteType.interpretation),
      ],
      'JHN 20:29': [
        Footnote(id: '1', text: '"blessed are they that have not seen, and yet have believed"', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Blessing on those who believe without physical evidence.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // ACTS
      // ============================================
      'ACT 1:8': [
        Footnote(id: '1', text: '"ye shall receive power" - Greek "dynamis", power, ability, strength.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"after that the Holy Ghost is come upon you" - Pentecost empowerment.', type: FootnoteType.theological),
        Footnote(id: '3', text: '"witnesses... unto the uttermost part of the earth" - Geographic expansion of the gospel.', type: FootnoteType.interpretation),
      ],
      'ACT 2:38': [
        Footnote(id: '1', text: '"Repent, and be baptized every one of you" - Peter\'s Pentecost message.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"for the remission of sins" - Baptism associated with forgiveness.', type: FootnoteType.interpretation),
        Footnote(id: '3', text: '"ye shall receive the gift of the Holy Ghost" - Spirit given to all believers.', type: FootnoteType.theological),
      ],
      'ACT 4:12': [
        Footnote(id: '1', text: '"Neither is there salvation in any other" - Exclusivity of Christ.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"for there is none other name under heaven given among men, whereby we must be saved."', type: FootnoteType.interpretation),
      ],
      'ACT 16:31': [
        Footnote(id: '1', text: '"Believe on the Lord Jesus Christ, and thou shalt be saved"', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Salvation by faith alone, through Christ alone.', type: FootnoteType.interpretation),
        Footnote(id: '3', text: '"thou and thy house" - Household salvation implied.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // ROMANS
      // ============================================
      'ROM 1:16': [
        Footnote(id: '1', text: '"I am not ashamed of the gospel of Christ" - Paul\'s confidence.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"it is the power of God unto salvation" - Gospel is God\'s saving power.', type: FootnoteType.theological),
        Footnote(id: '3', text: '"to every one that believeth" - Faith is the channel.', type: FootnoteType.interpretation),
      ],
      'ROM 1:17': [
        Footnote(id: '1', text: '"The just shall live by faith" - Quote from Habakkuk 2:4.', type: FootnoteType.crossReference),
        Footnote(id: '2', text: 'Key verse for the Reformation: justification by faith.', type: FootnoteType.theological),
      ],
      'ROM 3:10': [
        Footnote(id: '1', text: '"There is none righteous, no, not one" - Quote from Psalm 14:1-3.', type: FootnoteType.crossReference),
        Footnote(id: '2', text: 'Universal human sinfulness.', type: FootnoteType.theological),
      ],
      'ROM 3:23': [
        Footnote(id: '1', text: '"all have sinned" - Universal human sinfulness (Psalm 14:1-3).', type: FootnoteType.crossReference),
        Footnote(id: '2', text: '"come short of the glory of God" - Fall short of God\'s standard.', type: FootnoteType.interpretation),
      ],
      'ROM 3:24': [
        Footnote(id: '1', text: '"Justified freely by his grace" - Declared righteous without cost.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"through the redemption that is in Christ Jesus" - Christ\'s death purchases justification.', type: FootnoteType.theological),
      ],
      'ROM 5:1': [
        Footnote(id: '1', text: '"Therefore being justified by faith, we have peace with God"', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Peace: cessation of hostility between God and sinners.', type: FootnoteType.interpretation),
      ],
      'ROM 5:8': [
        Footnote(id: '1', text: '"But God commendeth his love toward us" - God demonstrated His love.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"while we were yet sinners, Christ died for us" - Christ died for the ungodly.', type: FootnoteType.interpretation),
      ],
      'ROM 6:23': [
        Footnote(id: '1', text: '"wages of sin is death" - Greek "opsonia", soldier\'s pay or rations.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"gift of God is eternal life" - Contrast: earned death vs. free gift.', type: FootnoteType.theological),
      ],
      'ROM 8:1': [
        Footnote(id: '1', text: '"There is therefore now no condemnation to them which are in Christ Jesus."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'No condemnation: legal verdict of acquittal.', type: FootnoteType.interpretation),
      ],
      'ROM 8:28': [
        Footnote(id: '1', text: '"all things work together for good" - Greek "sunergeo", to cooperate.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"to them that love God" - The promise is for believers.', type: FootnoteType.interpretation),
        Footnote(id: '3', text: '"called according to his purpose" - God\'s sovereign calling.', type: FootnoteType.theological),
      ],
      'ROM 8:38': [
        Footnote(id: '1', text: '"For I am persuaded" - Paul\'s absolute confidence.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"nor any other creature, shall be able to separate us from the love of God"', type: FootnoteType.theological),
      ],
      'ROM 8:39': [
        Footnote(id: '1', text: '"which is in Christ Jesus our Lord" - God\'s love is in Christ, secure.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Nothing can sever the believer from God\'s love.', type: FootnoteType.interpretation),
      ],
      'ROM 10:9': [
        Footnote(id: '1', text: '"If thou shalt confess with thy mouth the Lord Jesus" - Public confession.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"shalt believe in thine heart that God hath raised him from the dead" - Heart belief.', type: FootnoteType.interpretation),
      ],
      'ROM 10:10': [
        Footnote(id: '1', text: '"with the heart man believeth unto righteousness" - Heart belief leads to righteousness.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"with the mouth confession is made unto salvation" - Confession leads to salvation.', type: FootnoteType.interpretation),
      ],
      'ROM 10:13': [
        Footnote(id: '1', text: '"For whosoever shall call upon the name of the Lord shall be saved"', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Quote from Joel 2:32.', type: FootnoteType.crossReference),
        Footnote(id: '3', text: 'Universal offer: "whosoever" - anyone can be saved.', type: FootnoteType.interpretation),
      ],
      'ROM 12:1': [
        Footnote(id: '1', text: '"present your bodies a living sacrifice" - Total dedication to God.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"reasonable service" - Greek "logiken latreian", rational worship.', type: FootnoteType.linguistic),
      ],
      'ROM 12:2': [
        Footnote(id: '1', text: '"be not conformed to this world" - Greek "suschematizo", to mold after.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"be ye transformed" - Greek "metamorphoo", metamorphosis, inner change.', type: FootnoteType.linguistic),
        Footnote(id: '3', text: '"by the renewing of your mind" - Mind renewal leads to transformation.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // 1 CORINTHIANS
      // ============================================
      '1CO 1:18': [
        Footnote(id: '1', text: '"the preaching of the cross is to them that perish foolishness"', type: FootnoteType.theological),
        Footnote(id: '2', text: '"but unto us which are saved it is the power of God" - Different response to gospel.', type: FootnoteType.interpretation),
      ],
      '1CO 2:9': [
        Footnote(id: '1', text: '"Eye hath not seen, nor ear heard" - Quote from Isaiah 64:4.', type: FootnoteType.crossReference),
        Footnote(id: '2', text: '"the things which God hath prepared for them that love him" - Future glory.', type: FootnoteType.theological),
      ],
      '1CO 6:19': [
        Footnote(id: '1', text: '"your body is the temple of the Holy Ghost" - Indwelling Spirit.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"ye are not your own" - We belong to God.', type: FootnoteType.interpretation),
      ],
      '1CO 6:20': [
        Footnote(id: '1', text: '"For ye are bought with a price" - Christ\'s death purchased us.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"therefore glorify God in your body" - Purpose: God\'s glory.', type: FootnoteType.interpretation),
      ],
      '1CO 10:13': [
        Footnote(id: '1', text: '"God is faithful, who will not suffer you to be tempted above that ye are able"', type: FootnoteType.theological),
        Footnote(id: '2', text: '"make a way to escape" - God provides exit from temptation.', type: FootnoteType.interpretation),
      ],
      '1CO 13:4': [
        Footnote(id: '1', text: '"Charity suffereth long, and is kind" - Greek "agape", self-sacrificing love.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: 'Fifteen characteristics of love in this chapter.', type: FootnoteType.interpretation),
      ],
      '1CO 13:13': [
        Footnote(id: '1', text: '"And now abideth faith, hope, charity, these three" - Three eternal virtues.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"but the greatest of these is charity" - Love is supreme.', type: FootnoteType.interpretation),
      ],
      '1CO 15:10': [
        Footnote(id: '1', text: '"But by the grace of God I am what I am" - Paul\'s transformation by grace.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"his grace which was bestowed upon me was not in vain" - Grace produces works.', type: FootnoteType.interpretation),
      ],
      '1CO 15:58': [
        Footnote(id: '1', text: '"Therefore, my beloved brethren, be ye stedfast, unmoveable"', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"always abounding in the work of the Lord" - Diligent service.', type: FootnoteType.theological),
        Footnote(id: '3', text: '"your labour is not in vain in the Lord" - Eternal significance.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // 2 CORINTHIANS
      // ============================================
      '2CO 5:7': [
        Footnote(id: '1', text: '"For we walk by faith, not by sight" - Faith vs. visible evidence.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Christian life is lived by trust in God\'s promises.', type: FootnoteType.interpretation),
      ],
      '2CO 5:17': [
        Footnote(id: '1', text: '"Therefore if any man be in Christ, he is a new creature"', type: FootnoteType.theological),
        Footnote(id: '2', text: '"old things are passed away; behold, all things are become new" - Transformation.', type: FootnoteType.interpretation),
      ],
      '2CO 5:21': [
        Footnote(id: '1', text: '"For he hath made him to be sin for us, who knew no sin"', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Great exchange: Christ became sin; we become righteousness.', type: FootnoteType.interpretation),
        Footnote(id: '3', text: 'Imputation: our sin to Christ, His righteousness to us.', type: FootnoteType.theological),
      ],
      '2CO 9:7': [
        Footnote(id: '1', text: '"God loveth a cheerful giver" - Greek "hilaron", hilarious, joyful.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: 'Giving should be voluntary and joyful, not reluctant.', type: FootnoteType.interpretation),
      ],
      '2CO 12:9': [
        Footnote(id: '1', text: '"My grace is sufficient for thee" - God\'s answer to Paul\'s thorn.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"my strength is made perfect in weakness" - Power in weakness.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // GALATIANS
      // ============================================
      'GAL 2:20': [
        Footnote(id: '1', text: '"I am crucified with Christ" - Identification with Christ\'s death.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"nevertheless I live; yet not I, but Christ liveth in me" - Exchanged life.', type: FootnoteType.interpretation),
        Footnote(id: '3', text: '"the life which I now live in the flesh I live by the faith of the Son of God"', type: FootnoteType.theological),
      ],
      'GAL 5:22': [
        Footnote(id: '1', text: '"But the fruit of the Spirit is love, joy, peace" - Ninefold fruit.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"fruit" is singular - one fruit with nine manifestations.', type: FootnoteType.linguistic),
      ],
      'GAL 5:23': [
        Footnote(id: '1', text: '"against such there is no law" - The Spirit\'s fruit fulfills the law.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: 'Nine characteristics: love, joy, peace, patience, kindness, goodness, faithfulness, gentleness, self-control.', type: FootnoteType.interpretation),
      ],
      'GAL 6:7': [
        Footnote(id: '1', text: '"Be not deceived; God is not mocked" - Warning against self-deception.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"whatsoever a man soweth, that shall he also reap" - Law of sowing and reaping.', type: FootnoteType.interpretation),
      ],
      'GAL 6:9': [
        Footnote(id: '1', text: '"let us not be weary in well doing" - Persistence in good works.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"for in due season we shall reap, if we faint not" - Future harvest promised.', type: FootnoteType.theological),
      ],
      
      // ============================================
      // EPHESIANS
      // ============================================
      'EPH 2:8': [
        Footnote(id: '1', text: '"For by grace are ye saved through faith" - Salvation by grace through faith.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"and that not of yourselves: it is the gift of God" - Salvation is God\'s gift.', type: FootnoteType.interpretation),
        Footnote(id: '3', text: 'Grace is the source; faith is the channel; works are the result (verse 10).', type: FootnoteType.theological),
      ],
      'EPH 2:9': [
        Footnote(id: '1', text: '"Not of works, lest any man should boast" - No human boasting in salvation.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Works cannot earn salvation; salvation produces works.', type: FootnoteType.interpretation),
      ],
      'EPH 2:10': [
        Footnote(id: '1', text: '"For we are his workmanship" - Greek "poiema", masterpiece, work of art.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"created in Christ Jesus unto good works" - Good works are the purpose.', type: FootnoteType.theological),
      ],
      'EPH 4:32': [
        Footnote(id: '1', text: '"Be ye kind one to another, tenderhearted, forgiving one another"', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"even as God for Christ\'s sake hath forgiven you" - The standard: divine forgiveness.', type: FootnoteType.theological),
      ],
      'EPH 6:10': [
        Footnote(id: '1', text: '"Finally, my brethren, be strong in the Lord, and in the power of his might."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Spiritual strength comes from the Lord, not self.', type: FootnoteType.interpretation),
      ],
      'EPH 6:11': [
        Footnote(id: '1', text: '"Put on the whole armour of God" - Six pieces of armor listed.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"that ye may be able to stand against the wiles of the devil" - Spiritual warfare.', type: FootnoteType.interpretation),
      ],
      'EPH 6:17': [
        Footnote(id: '1', text: '"sword of the Spirit, which is the word of God" - The only offensive weapon.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: 'Scripture is the Spirit\'s weapon for spiritual warfare.', type: FootnoteType.theological),
      ],
      
      // ============================================
      // PHILIPPIANS
      // ============================================
      'PHP 1:6': [
        Footnote(id: '1', text: '"Being confident of this very thing, that he which hath begun a good work in you"', type: FootnoteType.theological),
        Footnote(id: '2', text: '"will perform it until the day of Jesus Christ" - God completes what He starts.', type: FootnoteType.interpretation),
      ],
      'PHP 2:5': [
        Footnote(id: '1', text: '"Let this mind be in you, which was also in Christ Jesus"', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Christ\'s humility is the model for believers.', type: FootnoteType.interpretation),
      ],
      'PHP 2:10': [
        Footnote(id: '1', text: '"That at the name of Jesus every knee should bow" - Universal acknowledgment.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Quote from Isaiah 45:23.', type: FootnoteType.crossReference),
      ],
      'PHP 4:4': [
        Footnote(id: '1', text: '"Rejoice in the Lord alway: and again I say, Rejoice."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Joy is commanded, not optional; "alway" means always.', type: FootnoteType.interpretation),
      ],
      'PHP 4:6': [
        Footnote(id: '1', text: '"Be careful for nothing" - Greek "merimnao", do not be anxious.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"but in every thing by prayer and supplication with thanksgiving let your requests be made known unto God."', type: FootnoteType.theological),
      ],
      'PHP 4:7': [
        Footnote(id: '1', text: '"And the peace of God, which passeth all understanding" - Divine peace.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"shall keep your hearts and minds through Christ Jesus" - Guarding peace.', type: FootnoteType.interpretation),
      ],
      'PHP 4:8': [
        Footnote(id: '1', text: '"whatsoever things are true... honest... just... pure... lovely... of good report"', type: FootnoteType.interpretation),
        Footnote(id: '2', text: 'Six positive qualities to think about.', type: FootnoteType.interpretation),
      ],
      'PHP 4:13': [
        Footnote(id: '1', text: '"I can do all things through Christ which strengtheneth me."', type: FootnoteType.theological),
        Footnote(id: '2', text: '"all things" - In context, contentment in all circumstances (verses 11-12).', type: FootnoteType.interpretation),
        Footnote(id: '3', text: 'Strength comes from Christ, not self.', type: FootnoteType.theological),
      ],
      'PHP 4:19': [
        Footnote(id: '1', text: '"But my God shall supply all your need" - God\'s provision.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"according to his riches in glory by Christ Jesus" - Limitless supply.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // COLOSSIANS
      // ============================================
      'COL 1:16': [
        Footnote(id: '1', text: '"For by him were all things created" - Christ\'s role in creation.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"all things were created by him, and for him" - Christ is the goal.', type: FootnoteType.interpretation),
      ],
      'COL 3:2': [
        Footnote(id: '1', text: '"Set your affection on things above, not on things on the earth."', type: FootnoteType.interpretation),
        Footnote(id: '2', text: 'Heavenly focus transforms earthly living.', type: FootnoteType.theological),
      ],
      'COL 3:23': [
        Footnote(id: '1', text: '"Whatsoever ye do, do it heartily, as to the Lord, and not unto men"', type: FootnoteType.theological),
        Footnote(id: '2', text: 'All work is sacred when done for the Lord.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // 1 THESSALONIANS
      // ============================================
      '1TH 5:16': [
        Footnote(id: '1', text: '"Rejoice evermore" - Continuous joy commanded.', type: FootnoteType.theological),
      ],
      '1TH 5:17': [
        Footnote(id: '1', text: '"Pray without ceasing" - Continuous prayer life.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Not nonstop prayer, but continual communion with God.', type: FootnoteType.interpretation),
      ],
      '1TH 5:18': [
        Footnote(id: '1', text: '"In every thing give thanks" - Gratitude in all circumstances.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"for this is the will of God in Christ Jesus concerning you" - God\'s will: thankfulness.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // 2 TIMOTHY
      // ============================================
      '2TI 1:7': [
        Footnote(id: '1', text: '"For God hath not given us the spirit of fear" - Fear is not from God.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"but of power, and of love, and of a sound mind" - Three gifts: power, love, self-discipline.', type: FootnoteType.interpretation),
      ],
      '2TI 2:15': [
        Footnote(id: '1', text: '"Study to shew thyself approved unto God" - Diligent study required.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"a workman that needeth not to be ashamed" - Competent handling of Scripture.', type: FootnoteType.theological),
        Footnote(id: '3', text: '"rightly dividing the word of truth" - Accurate interpretation.', type: FootnoteType.interpretation),
      ],
      '2TI 3:16': [
        Footnote(id: '1', text: '"All scripture is given by inspiration of God" - Greek "theopneustos", God-breathed.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"profitable for doctrine, reproof, correction, instruction in righteousness" - Four purposes.', type: FootnoteType.interpretation),
      ],
      '2TI 3:17': [
        Footnote(id: '1', text: '"That the man of God may be perfect" - Greek "artios", complete, equipped.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"throughly furnished unto all good works" - Scripture equips for service.', type: FootnoteType.theological),
      ],
      
      // ============================================
      // TITUS
      // ============================================
      'TIT 2:11': [
        Footnote(id: '1', text: '"For the grace of God that bringeth salvation hath appeared to all men."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Grace is the source of salvation, available to all.', type: FootnoteType.interpretation),
      ],
      'TIT 3:5': [
        Footnote(id: '1', text: '"Not by works of righteousness which we have done" - Works cannot save.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"but according to his mercy he saved us" - Salvation by mercy.', type: FootnoteType.interpretation),
        Footnote(id: '3', text: '"by the washing of regeneration, and renewing of the Holy Ghost" - New birth.', type: FootnoteType.theological),
      ],
      
      // ============================================
      // HEBREWS
      // ============================================
      'HEB 1:3': [
        Footnote(id: '1', text: '"Who being the brightness of his glory" - Greek "apaugasma", radiance.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"express image of his person" - Greek "charakter", exact representation.', type: FootnoteType.linguistic),
        Footnote(id: '3', text: '"by himself purged our sins" - Christ\'s self-sacrifice for sin.', type: FootnoteType.theological),
      ],
      'HEB 4:12': [
        Footnote(id: '1', text: '"quick, and powerful" - Greek "zon...energes", living and active.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"sharper than any twoedged sword" - Scripture penetrates deeply.', type: FootnoteType.interpretation),
        Footnote(id: '3', text: '"dividing asunder of soul and spirit" - Scripture discerns inner thoughts.', type: FootnoteType.theological),
      ],
      'HEB 4:14': [
        Footnote(id: '1', text: '"Seeing then that we have a great high priest" - Jesus as high priest.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"that is passed into the heavens, Jesus the Son of God" - Ascended Christ.', type: FootnoteType.interpretation),
      ],
      'HEB 4:15': [
        Footnote(id: '1', text: '"For we have not an high priest which cannot be touched with the feeling of our infirmities"', type: FootnoteType.theological),
        Footnote(id: '2', text: '"but was in all points tempted like as we are, yet without sin" - Sympathetic high priest.', type: FootnoteType.interpretation),
      ],
      'HEB 4:16': [
        Footnote(id: '1', text: '"Let us therefore come boldly unto the throne of grace" - Confident access.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"obtain mercy, and find grace to help in time of need" - Grace and mercy available.', type: FootnoteType.interpretation),
      ],
      'HEB 11:1': [
        Footnote(id: '1', text: '"substance" - Greek "hypostasis", confidence, assurance, reality.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: '"evidence" - Greek "elenchos", conviction, proof.', type: FootnoteType.linguistic),
        Footnote(id: '3', text: 'Faith is confident assurance in God\'s promises.', type: FootnoteType.theological),
      ],
      'HEB 11:6': [
        Footnote(id: '1', text: '"But without faith it is impossible to please him" - Faith is essential.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"he that cometh to God must believe that he is" - Belief in God\'s existence.', type: FootnoteType.interpretation),
        Footnote(id: '3', text: '"he is a rewarder of them that diligently seek him" - God rewards seekers.', type: FootnoteType.theological),
      ],
      'HEB 13:5': [
        Footnote(id: '1', text: '"Let your conversation be without covetousness" - Contentment commanded.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"I will never leave thee, nor forsake thee" - Quote from Deuteronomy 31:6.', type: FootnoteType.crossReference),
      ],
      'HEB 13:8': [
        Footnote(id: '1', text: '"Jesus Christ the same yesterday, and to day, and for ever."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Christ\'s immutability: He never changes.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // JAMES
      // ============================================
      'JAS 1:2': [
        Footnote(id: '1', text: '"Count it all joy when ye fall into divers temptations" - Joy in trials.', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Trials are occasions for joy, not just endurance.', type: FootnoteType.interpretation),
      ],
      'JAS 1:3': [
        Footnote(id: '1', text: '"Knowing this, that the trying of your faith worketh patience."', type: FootnoteType.interpretation),
        Footnote(id: '2', text: 'Greek "dokimion", testing proves genuine faith.', type: FootnoteType.linguistic),
      ],
      'JAS 1:5': [
        Footnote(id: '1', text: '"If any of you lack wisdom, let him ask of God" - Prayer for wisdom.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"giveth to all men liberally, and upbraideth not" - God gives generously.', type: FootnoteType.interpretation),
      ],
      'JAS 1:22': [
        Footnote(id: '1', text: '"But be ye doers of the word, and not hearers only" - Application required.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"deceiving your own selves" - Self-deception in hearing without doing.', type: FootnoteType.interpretation),
      ],
      'JAS 2:17': [
        Footnote(id: '1', text: '"Even so faith, if it hath not works, is dead, being alone."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'True faith produces works; works evidence genuine faith.', type: FootnoteType.interpretation),
      ],
      'JAS 2:19': [
        Footnote(id: '1', text: '"Thou believest that there is one God; thou doest well: the devils also believe, and tremble."', type: FootnoteType.interpretation),
        Footnote(id: '2', text: 'Intellectual belief is not saving faith.', type: FootnoteType.theological),
      ],
      'JAS 4:7': [
        Footnote(id: '1', text: '"Submit yourselves therefore to God" - Submission precedes resistance.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"Resist the devil, and he will flee from you" - Resistance through submission.', type: FootnoteType.interpretation),
      ],
      'JAS 4:8': [
        Footnote(id: '1', text: '"Draw nigh to God, and he will draw nigh to you" - Reciprocal nearness.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"Cleanse your hands, ye sinners; and purify your hearts, ye double minded."', type: FootnoteType.interpretation),
      ],
      'JAS 5:16': [
        Footnote(id: '1', text: '"Confess your faults one to another" - Mutual confession.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"pray one for another, that ye may be healed" - Intercessory prayer.', type: FootnoteType.theological),
        Footnote(id: '3', text: '"The effectual fervent prayer of a righteous man availeth much" - Powerful prayer.', type: FootnoteType.theological),
      ],
      
      // ============================================
      // 1 PETER
      // ============================================
      '1PE 2:9': [
        Footnote(id: '1', text: '"But ye are a chosen generation, a royal priesthood, an holy nation"', type: FootnoteType.theological),
        Footnote(id: '2', text: '"a peculiar people" - Greek "peripoiesis", God\'s own possession.', type: FootnoteType.linguistic),
        Footnote(id: '3', text: '"shew forth the praises of him who hath called you" - Purpose: proclaim God.', type: FootnoteType.interpretation),
      ],
      '1PE 3:15': [
        Footnote(id: '1', text: '"sanctify the Lord God in your hearts" - Set apart Christ as Lord.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"be ready always to give an answer" - Greek "apologia", defense.', type: FootnoteType.linguistic),
        Footnote(id: '3', text: '"to every man that asketh you a reason of the hope that is in you" - Apologetics.', type: FootnoteType.interpretation),
      ],
      '1PE 5:7': [
        Footnote(id: '1', text: '"Casting all your care upon him; for he careth for you."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Greek "merimnan", anxieties, worries.', type: FootnoteType.linguistic),
        Footnote(id: '3', text: 'God invites us to unload our burdens on Him.', type: FootnoteType.interpretation),
      ],
      '1PE 5:8': [
        Footnote(id: '1', text: '"Be sober, be vigilant" - Alertness and self-control.', type: FootnoteType.interpretation),
        Footnote(id: '2', text: '"your adversary the devil, as a roaring lion, walketh about, seeking whom he may devour"', type: FootnoteType.theological),
      ],
      
      // ============================================
      // 2 PETER
      // ============================================
      '2PE 1:3': [
        Footnote(id: '1', text: '"According as his divine power hath given unto us all things that pertain unto life and godliness"', type: FootnoteType.theological),
        Footnote(id: '2', text: 'God provides everything needed for spiritual life.', type: FootnoteType.interpretation),
      ],
      '2PE 3:9': [
        Footnote(id: '1', text: '"The Lord is not slack concerning his promise" - God keeps His word.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"not willing that any should perish, but that all should come to repentance"', type: FootnoteType.interpretation),
        Footnote(id: '3', text: 'God\'s patience delays judgment for salvation.', type: FootnoteType.theological),
      ],
      
      // ============================================
      // 1 JOHN
      // ============================================
      '1JN 1:9': [
        Footnote(id: '1', text: '"If we confess our sins, he is faithful and just to forgive us our sins"', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Confession brings forgiveness; God is faithful to His promise.', type: FootnoteType.interpretation),
        Footnote(id: '3', text: '"cleanse us from all unrighteousness" - Complete cleansing.', type: FootnoteType.theological),
      ],
      '1JN 4:4': [
        Footnote(id: '1', text: '"Ye are of God, little children, and have overcome them"', type: FootnoteType.theological),
        Footnote(id: '2', text: '"greater is he that is in you, than he that is in the world" - The indwelling Spirit.', type: FootnoteType.interpretation),
      ],
      '1JN 4:7': [
        Footnote(id: '1', text: '"Beloved, let us love one another: for love is of God"', type: FootnoteType.theological),
        Footnote(id: '2', text: '"every one that loveth is born of God, and knoweth God" - Love evidences new birth.', type: FootnoteType.interpretation),
      ],
      '1JN 4:8': [
        Footnote(id: '1', text: '"He that loveth not knoweth not God; for God is love."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Love is not just an attribute; it is God\'s essence.', type: FootnoteType.interpretation),
      ],
      '1JN 4:18': [
        Footnote(id: '1', text: '"There is no fear in love; but perfect love casteth out fear"', type: FootnoteType.theological),
        Footnote(id: '2', text: '"fear hath torment" - Fear and love are incompatible.', type: FootnoteType.interpretation),
      ],
      '1JN 5:14': [
        Footnote(id: '1', text: '"And this is the confidence that we have in him" - Boldness in prayer.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"if we ask any thing according to his will, he heareth us" - Prayer according to God\'s will.', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // JUDE
      // ============================================
      'JUD 1:24': [
        Footnote(id: '1', text: '"Now unto him that is able to keep you from falling" - God\'s keeping power.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"to present you faultless before the presence of his glory with exceeding joy"', type: FootnoteType.interpretation),
      ],
      
      // ============================================
      // REVELATION
      // ============================================
      'REV 1:8': [
        Footnote(id: '1', text: '"I am Alpha and Omega, the beginning and the ending" - First and last letters.', type: FootnoteType.linguistic),
        Footnote(id: '2', text: 'Title applied to God the Father and later to Christ (22:13).', type: FootnoteType.theological),
        Footnote(id: '3', text: '"which is, and which was, and which is to come, the Almighty" - Eternal God.', type: FootnoteType.interpretation),
      ],
      'REV 3:20': [
        Footnote(id: '1', text: '"Behold, I stand at the door, and knock" - Christ seeking entrance.', type: FootnoteType.theological),
        Footnote(id: '2', text: '"if any man hear my voice, and open the door, I will come in to him"', type: FootnoteType.interpretation),
        Footnote(id: '3', text: '"will sup with him, and he with me" - Fellowship and communion.', type: FootnoteType.interpretation),
      ],
      'REV 21:4': [
        Footnote(id: '1', text: '"And God shall wipe away all tears from their eyes"', type: FootnoteType.theological),
        Footnote(id: '2', text: '"there shall be no more death, neither sorrow, nor crying, neither shall there be any more pain"', type: FootnoteType.interpretation),
        Footnote(id: '3', text: 'Complete removal of all effects of the curse.', type: FootnoteType.theological),
      ],
      'REV 22:13': [
        Footnote(id: '1', text: '"I am Alpha and Omega, the beginning and the end, the first and the last."', type: FootnoteType.theological),
        Footnote(id: '2', text: 'Christ claims the same title as the Father in 1:8.', type: FootnoteType.crossReference),
      ],
      'REV 22:20': [
        Footnote(id: '1', text: '"He which testifieth these things saith, Surely I come quickly."', type: FootnoteType.theological),
        Footnote(id: '2', text: '"Amen. Even so, come, Lord Jesus" - The church\'s response: Maranatha.', type: FootnoteType.interpretation),
      ],
    });
    
    // Cross-references (keeping existing ones and adding more)
    _crossReferences.addAll({
      'GEN 1:1': [
        CrossReference(reference: 'John 1:1-3', text: 'Christ as the Word in creation'),
        CrossReference(reference: 'Colossians 1:16', text: 'All things created through Christ'),
        CrossReference(reference: 'Hebrews 1:2', text: 'God created worlds through His Son'),
      ],
      'GEN 3:15': [
        CrossReference(reference: 'Galatians 4:4', text: 'Christ born of woman'),
        CrossReference(reference: 'Romans 16:20', text: 'God will crush Satan'),
        CrossReference(reference: 'Revelation 12:9', text: 'The ancient serpent identified'),
      ],
      'PSA 23:1': [
        CrossReference(reference: 'John 10:11', text: 'Jesus the Good Shepherd'),
        CrossReference(reference: 'Hebrews 13:20', text: 'Our Lord Jesus, the great Shepherd'),
        CrossReference(reference: '1 Peter 2:25', text: 'The Shepherd and Overseer of souls'),
      ],
      'ISA 7:14': [
        CrossReference(reference: 'Matthew 1:23', text: 'Fulfilled in Jesus\' birth'),
        CrossReference(reference: 'Luke 1:31', text: 'Mary told to name Him Jesus'),
      ],
      'JHN 3:16': [
        CrossReference(reference: 'Romans 5:8', text: 'God demonstrates His love'),
        CrossReference(reference: '1 John 4:9', text: 'God sent His only Son'),
        CrossReference(reference: 'Ephesians 2:4-5', text: 'Made alive with Christ'),
      ],
      'ROM 3:23': [
        CrossReference(reference: 'Romans 3:10', text: 'None righteous, no not one'),
        CrossReference(reference: 'Ecclesiastes 7:20', text: 'No one who does not sin'),
        CrossReference(reference: '1 John 1:8', text: 'If we say we have no sin'),
      ],
      'EPH 2:8': [
        CrossReference(reference: 'Romans 3:24', text: 'Justified by grace'),
        CrossReference(reference: 'Titus 3:5', text: 'Not by works of righteousness'),
        CrossReference(reference: 'Romans 6:23', text: 'Gift of God is eternal life'),
      ],
      'PHP 4:13': [
        CrossReference(reference: '2 Corinthians 12:9', text: 'God\'s grace is sufficient'),
        CrossReference(reference: 'Philippians 4:19', text: 'God supplies all needs'),
      ],
      'HEB 4:16': [
        CrossReference(reference: 'Ephesians 3:12', text: 'Boldness and access'),
        CrossReference(reference: 'Hebrews 10:19-22', text: 'Enter the holy place'),
      ],
      'JAS 1:5': [
        CrossReference(reference: 'Proverbs 2:6', text: 'Lord gives wisdom'),
        CrossReference(reference: 'Colossians 2:3', text: 'Christ, in whom are hidden treasures of wisdom'),
      ],
      '1JN 1:9': [
        CrossReference(reference: 'Psalm 32:5', text: 'David confesses and is forgiven'),
        CrossReference(reference: 'Proverbs 28:13', text: 'Whoever confesses finds mercy'),
      ],
      'REV 3:20': [
        CrossReference(reference: 'John 10:9', text: 'I am the door'),
        CrossReference(reference: 'Luke 12:36', text: 'Waiting for the master to return'),
      ],
    });
  }
  
  /// Get footnotes for a specific verse
  List<Footnote> getFootnotes(String bookId, int chapter, int verse) {
    final key = '${bookId.toUpperCase()} $chapter:$verse';
    return _footnotes[key] ?? [];
  }
  
  /// Get cross-references for a specific verse
  List<CrossReference> getCrossReferences(String bookId, int chapter, int verse) {
    final key = '${bookId.toUpperCase()} $chapter:$verse';
    return _crossReferences[key] ?? [];
  }
  
  /// Get all footnotes for a chapter
  Map<String, List<Footnote>> getChapterFootnotes(String bookId, int chapter) {
    final result = <String, List<Footnote>>{};
    
    _footnotes.forEach((key, value) {
      if (key.startsWith('${bookId.toUpperCase()} $chapter:')) {
        result[key] = value;
      }
    });
    
    return result;
  }
  
  /// Search footnotes by text
  List<MapEntry<String, Footnote>> searchFootnotes(String query) {
    final results = <MapEntry<String, Footnote>>[];
    final lowerQuery = query.toLowerCase();
    
    _footnotes.forEach((verseId, footnotes) {
      for (final footnote in footnotes) {
        if (footnote.text.toLowerCase().contains(lowerQuery)) {
          results.add(MapEntry(verseId, footnote));
        }
      }
    });
    
    return results;
  }
  
  /// Get footnote count
  int get totalFootnotes => _footnotes.values.fold(0, (sum, list) => sum + list.length);
  int get totalCrossReferences => _crossReferences.values.fold(0, (sum, list) => sum + list.length);
  int get totalVersesWithFootnotes => _footnotes.length;
  
  /// Get all books that have footnotes
  List<String> getBooksWithFootnotes() {
    final books = <String>{};
    _footnotes.keys.forEach((key) {
      final book = key.split(' ').first;
      books.add(book);
    });
    return books.toList()..sort();
  }
}

/// Footnote model
class Footnote {
  final String id;
  final String text;
  final FootnoteType type;
  
  const Footnote({
    required this.id,
    required this.text,
    required this.type,
  });
  
  factory Footnote.fromJson(Map<String, dynamic> json) => Footnote(
    id: json['id'] ?? '',
    text: json['text'] ?? '',
    type: FootnoteType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => FootnoteType.general,
    ),
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'type': type.name,
  };
}

/// Footnote types
enum FootnoteType {
  general,
  linguistic,
  translation,
  theological,
  historical,
  cultural,
  interpretation,
  crossReference,
  messianic,
}

/// Cross-reference model
class CrossReference {
  final String reference;
  final String text;
  
  const CrossReference({
    required this.reference,
    required this.text,
  });
  
  factory CrossReference.fromJson(Map<String, dynamic> json) => CrossReference(
    reference: json['reference'] ?? '',
    text: json['text'] ?? '',
  );
  
  Map<String, dynamic> toJson() => {
    'reference': reference,
    'text': text,
  };
}
