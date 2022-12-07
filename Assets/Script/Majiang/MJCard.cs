using UnityEngine;
using System.Collections.Generic;
using DG.Tweening;
    /// <summary>
    /// 单张麻将牌
    /// </summary>
    public class MJCard :MonoBehaviour
    {
        [SerializeField] public GameObject card;//牌身gameObject
        [SerializeField] private MeshRenderer _renderer;// 渲染器组件

        public int cardValue;// 麻将牌值
        public int cardIndexInHand = -1;// 麻将在自己手牌里的标识 不在自己手牌里为-1
        private bool _enableClicked = true;
        private Dictionary<Material, Color> _originColors;
        public bool EnableClicked => _enableClicked;
        //手牌麻将变暗与桌面麻将变蓝 的材质球颜色定义
        public static Dictionary<string, Color32> MJCardMatDarkColor = new()
        {
            { "JC_MaJiangZi_BeiMian_D_SP", new Color32(168,187,204,255)},
            { "JC_MaJiangZi_ZhenMian_D_SP", new Color32(147,148,148,255)},
            { "JC_MaJiangZi_BaiSe_D_SP", new Color32(147,148,148,255)}
        };
        public static Dictionary<string, Color32> MJCardMatBlueColor = new()
        {
            { "JC_MaJiangZi_BeiMian_D", new Color32(151,194,217,255)},
            { "JC_MaJiangZi_ZhengMian_D", new Color32(151,194,217,255)},
            { "JC_MaJiangZi_BaiSe_D", new Color32(151,194,217,255)}
        };

        protected  void Init()
        {
            SetupOriginColors();
        }

        private void SetupOriginColors()
        {
            _originColors = new Dictionary<Material, Color>();
            for (int i = 0; i < _renderer.materials.Length; i++)
            {
                var mat = _renderer.materials[i];
                if (mat != null)
                {
                    _originColors.Add(mat, mat.GetColor("_BaseColor"));
                }
            }
        }

        public void OnInitialized(int value)
        {
            cardValue = value;
            gameObject.name = $"mjcard_{cardValue}";
            SetUpMaterial();
        }

        /// <summary>
        /// 设置牌是否可以点击
        /// </summary>
        /// <param name="enable"></param>
        public void SetEnableClicked(bool enable)
        {
            _enableClicked = enable;
        }
        
        /// <summary>
        /// 牌抬起
        /// </summary>
        public void CardLift()
        {
            transform.localPosition += Vector3.up * MJConst.MJCardSizeLenth * 0.5f;
        }

        /// <summary>
        /// 牌落下
        /// </summary>
        /// <param name="obj"></param>
        public void CardFall()
        {
            var pos = transform.localPosition;
            float y = 0f;
            transform.localPosition = new Vector3(pos.x, y, pos.z);
        }
        public Tween CardFilp(CardFilpDirct filpDirct)
        {
            Tween tween = null;
            switch (filpDirct)
            {
                case CardFilpDirct.Up:
                    tween = transform.DOLocalRotateQuaternion(Quaternion.Euler(Vector3.zero),0.4f).SetAutoKill(true);
                    break;
                case CardFilpDirct.Vertical:
                    tween = transform.DOLocalRotateQuaternion(Quaternion.Euler(MJConst.MJCard_Stand), 0.4f).SetAutoKill(true);
                    break;
                case CardFilpDirct.Back:
                    tween = transform.DOLocalRotateQuaternion(Quaternion.Euler(MJConst.MJCard_CardBack), 0.4f).SetAutoKill(true);
                    break;
            }
            return tween;
        }
        public void SetDarkColor()
        {
            for (int i = 0; i < _renderer.materials.Length; i++)
            {
                var mat = _renderer.materials[i];
                if (mat != null)
                {
                    string _name = mat.name.Replace(" (Instance)",string.Empty);
                    if( MJCardMatDarkColor.TryGetValue(_name,out Color32 color))
                    {
                        mat.SetColor("_BaseColor", color);
                    }
                }
            }
        }
        public void SetBlueColor()
        {
            for (int i = 0; i < _renderer.materials.Length; i++)
            {
                var mat = _renderer.materials[i];
                if (mat != null)
                {
                    string _name = mat.name.Replace(" (Instance)", string.Empty);
                    if (MJCardMatBlueColor.TryGetValue(_name, out Color32 color))
                    {
                        mat.SetColor("_BaseColor", color);
                    }
                }
            }
        }

        public void ResetColor()
        {
            foreach(var pair in _originColors)
            {
                pair.Key.SetColor("_BaseColor", pair.Value);
            }
        }
        public void SetLightLayer(uint layer)
        {
            _renderer.renderingLayerMask = layer;
        }
       

        /// <summary>
        /// 设置牌花uv偏移
        /// </summary>
        private void SetUpMaterial()
        {
            for (int i = 0; i < _renderer.materials.Length; i++)
            {
                var mat = _renderer.materials[i];
                if (mat != null)
                {
                    if (MJConst.MJCardMatOffsets.ContainsKey(cardValue) == false)
                    {
                        return;
                    }

                    var offset = MJConst.MJCardMatOffsets[cardValue];
                    mat.SetFloat("_Row", offset.x);
                    mat.SetFloat("_Col", offset.y);
                }
            }
        }

        /*public static MJCard Create(int cardValue)
        {
            var prefab = SystemResManager.Instance.Load<GameObject>(ResPath.Shared_MJCard);

            var go = GameObject.Instantiate(prefab);

            MJCard card = go.GetComponent<MJCard>();

            card.OnInitialized(cardValue);

            return card;
        }

        public void LoadMaterial(bool isDefalt)
        {
            string _path = isDefalt ? ResPath.Shared_DeskCard : ResPath.Shared_HandCard;


            var _mat1 = Instantiate(SystemResManager.Instance.Load<GameObject>(_path)).GetComponent<MeshRenderer>();
            _renderer.materials = new Material[3] { _mat1.materials[0], _mat1.materials[1], _mat1.materials[2] };
            Destroy(_mat1.gameObject);
            _renderer.UpdateGIMaterials();

            SetupOriginColors();
        }*/
    }

    public enum CardFilpDirct
    {
        Up,
        Vertical,
        Back
    }